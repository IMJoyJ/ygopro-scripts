--星逢の天河
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只仪式怪兽给对方观看才能发动。和那只怪兽是卡名不同并是等级相同的1只仪式怪兽从卡组加入手卡。
-- ②：把墓地的这张卡除外，从手卡把1张仪式魔法卡送去墓地才能发动。这个效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
local s,id,o=GetID()
-- 为『星逢的天河』注册两个效果：e1为①效果（发动时展示手牌仪式怪兽，检索同名不同、等级相同的仪式怪兽），e2为②效果（在墓地除外自身并丢弃手牌仪式魔法，复制其仪式召唤效果）。两者均设定了1回合1次使用次数限制，e1为通常魔法发动的自由时点效果，e2为墓地发动的二速诱发即时效果。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把手卡1只仪式怪兽给对方观看才能发动。和那只怪兽是卡名不同并是等级相同的1只仪式怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把墓地的这张卡除外，从手卡把1张仪式魔法卡送去墓地才能发动。这个效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(s.rscost)
	e2:SetTarget(s.rstg)
	e2:SetOperation(s.rsop)
	c:RegisterEffect(e2)
end
-- ①效果的代价判定：先将效果e的标签设为100，用于标记『已通过展示手牌仪式怪兽的前置条件』，随后返回true表示满足发动代价；实际展示对方确认的操作在目标选择阶段（s.target）进行。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤手牌中可作为展示对象的卡：该卡必须是仪式怪兽（类型位与0x81按位与等于0x81，即怪兽+仪式），且不是公开状态；同时要求卡组中存在满足s.thfilter的检索对象。
function s.cfilter(c,tp)
	return bit.band(c:GetType(),0x81)==0x81 and not c:IsPublic()
		-- 进一步判定卡组中是否存在至少1张符合条件的仪式怪兽，该怪兽需以当前展示候选卡c为基准：卡名不同、等级相同、且为可加入手卡的仪式怪兽。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤卡组中可被检索的仪式怪兽：与展示怪兽（rc）卡名不同、等级相同、类型为仪式怪兽，并且不能被『不能加入手卡』等效果妨碍（IsAbleToHand为true）。
function s.thfilter(c,rc)
	return not c:IsCode(rc:GetCode()) and c:IsLevel(rc:GetLevel())
		and bit.band(c:GetType(),0x81)==0x81
		and c:IsAbleToHand()
end
-- ①效果的目标选择与发动处理：在合法性检查时确认已通过代价标记且手牌存在满足cfilter的仪式怪兽；在发动时提示玩家选择1张手牌仪式怪兽展示给对方，保存该卡到标签对象，洗切手牌，并设置操作信息为从卡组检索1张卡加入手牌。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查手牌中是否存在至少1张满足cfilter条件的仪式怪兽可用来展示，从而决定①效果能否发动。
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 向当前玩家显示选择消息，提示其从手牌选择一张要展示给对方确认的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 令当前玩家从手牌中选出1张满足cfilter条件的仪式怪兽（额外参数tp用于卡组检索判断），该卡将被用于展示。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选出的手牌仪式怪兽展示给对方玩家确认，满足『给对方观看』这一发动条件。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切手牌，使手牌顺序重新隐藏，避免公开信息残留。
	Duel.ShuffleHand(tp)
	-- 设置当前连锁的操作信息：本效果将进行从卡组把1张卡加入手牌的处理（CATEGORY_TOHAND）；由于具体检索目标在处理时才确定，故targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：根据目标阶段记录下的展示怪兽，从卡组选出1张同名不同、等级相同的仪式怪兽加入手牌，并向对方展示确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示当前玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local rc=e:GetLabelObject()
	-- 从卡组中选出1张满足s.thfilter条件、以记录展示怪兽rc为基准的仪式怪兽，作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,rc)
	if g:GetCount()>0 then
		-- 将选中的仪式怪兽加入其持有者的手卡，原因记为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将实际加入手牌的仪式怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤手牌中可作为②效果复制对象的仪式魔法卡：必须是仪式魔法（类型等于魔法+仪式），可以作为代价送入墓地，并且其发动时存在需要处理的仪式召唤效果（CheckActivateEffect返回非nil）。
function s.rtfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
-- ②效果的代价判定：仅将效果e的标签设为1，返回true表示代价可支付；实际除外墓地的这张卡和从手牌丢弃仪式魔法卡的操作在目标选择阶段（s.rstg）完成。
function s.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- ②效果的目标选择与发动处理：合法性检查时确认已通过代价标记、手牌存在仪式魔法卡且墓地此卡可除外；发动时选择手牌1张仪式魔法卡，获取其发动时的效果对象，将仪式魔法卡送墓、自身除外，并把该效果对象的Property属性复制到当前效果上，同时调用其Target函数完成目标设定，最后清除操作信息，以避免后续被错误响应。
function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查手牌中是否存在至少1张满足rtfilter条件的仪式魔法卡可用作代价，同时墓地的这张卡能否除外，以此作为②效果能否发动的依据。
		return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_HAND,0,1,nil)
			and c:IsAbleToRemoveAsCost()
	end
	e:SetLabel(0)
	-- 显示选择提示，提示当前玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择1张满足rtfilter条件的仪式魔法卡，该卡将被作为复制对象送入墓地。
	local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_HAND,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabelObject(te)
	-- 将选中的仪式魔法卡作为代价从手牌送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
	-- 将墓地的这张『星逢的天河』以表侧表示除外，作为②效果的另一个代价。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息，避免复制仪式召唤效果时被其他卡误判为常规检索/特殊召唤等行为而进行对应。
	Duel.ClearOperationInfo(0)
end
-- ②效果处理：取出之前保存的仪式魔法卡效果对象，调用其Operation函数，使本效果实际执行与那张仪式魔法卡发动时相同的仪式召唤效果。
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
