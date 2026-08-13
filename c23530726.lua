--閃術兵器－Ｓ．Ｐ．Ｅ．Ｃ．Ｔ．Ｒ．Ａ．
-- 效果：
-- 包含连接怪兽的怪兽2只以上
-- 这个卡名在规则上也当作「闪刀姬」卡使用。这张卡不用连接召唤不能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：连锁2以后对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·墓地把2张魔法卡除外才能发动。那个效果无效。那之后，可以把对方场上1张卡破坏。
-- ②：自己墓地没有魔法卡存在的场合，这张卡的攻击力下降3000。
local s,id,o=GetID()
-- 定义该卡片的全部效果初始化流程：设置连接召唤素材条件（至少2只怪兽且含连接怪兽）、赋予复活限制、注册②攻击力下降永续效果、连接召唤限制条件，以及①的诱发即时效果。
function s.initial_effect(c)
	-- 设置连接召唤手续：需要2只以上怪兽作为连接素材，且素材组中至少包含1只连接怪兽（由s.lcheck保证），以满足“包含连接怪兽的怪兽2只以上”的出场条件。
	aux.AddLinkProcedure(c,nil,2,nil,s.lcheck)
	c:EnableReviveLimit()
	-- ②：自己墓地没有魔法卡存在的场合，这张卡的攻击力下降3000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.atcon)
	e1:SetValue(-3000)
	c:RegisterEffect(e1)
	-- 这个卡名在规则上也当作「闪刀姬」卡使用。这张卡不用连接召唤不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 将特殊召唤条件的效果值设为aux.linklimit，即只允许通过连接召唤方式从额外卡组特殊召唤，其他非连接召唤的方式均不能将其特殊召唤。
	e2:SetValue(aux.linklimit)
	c:RegisterEffect(e2)
	-- 这个卡名的①的效果1回合只能使用1次。①：连锁2以后对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·墓地把2张魔法卡除外才能发动。那个效果无效。那之后，可以把对方场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 定义连接素材的追加过滤条件：作为连接素材的怪兽组中必须至少有1只连接怪兽，即满足“包含连接怪兽的怪兽2只以上”的素材构成。
function s.lcheck(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- 定义②攻击力下降效果的适用条件：当这张卡的控制者墓地中不存在任何魔法卡时，该永续效果适用。
function s.atcon(e)
	-- 返回“控制者墓地中没有魔法卡”的判断结果：若墓地不存在魔法卡则为true，使攻击力下降效果生效。
	return not Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,TYPE_SPELL)
end
-- 定义①效果的发动条件：必须由对方发动魔法·陷阱·怪兽效果，且该效果处于连锁2或更高的连锁上时才允许发动。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方（ep==1-tp）发动效果，且当前连锁数≥2，两项条件同时满足时发动条件成立。
	return ep==1-tp and Duel.GetCurrentChain()>=2
end
-- 定义代价的过滤函数：从手卡·墓地中筛选出可作为cost除外的魔法卡（满足魔法卡类型且可除外）。
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 定义代价的支付过程：先检查是否存在至少2张符合条件的魔法卡；若有，提示玩家选择2张，并以表侧表示除外作为发动代价。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段（chk==0）确认自己的手卡·墓地中是否存在至少2张满足条件的魔法卡，以此作为能否发动的代价条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示信息，用于选择除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的手卡·墓地中选出2张符合条件的魔法卡，作为本次效果的代价。
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,nil)
	-- 将所选2张魔法卡以表侧表示除外，完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义①效果发动时的目标处理：无特定对象要求（chk==0直接通过），并将使对方发动的那个效果无效的信息记录到操作信息中。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁中对方发动的效果（eg）标记为“将被无效”的对象，数量为1，用于效果处理时执行无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义①效果处理流程：先使对方发动的那个效果无效；若无效成功且对方场上存在卡，则询问是否破坏对方场上1张卡，选择后予以破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的全部卡（表侧或里侧）作为可能被破坏的候选集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 执行对方效果无效；若无效成功且候选集合非空，则询问玩家是否要追加破坏对方场上1张卡。
	if Duel.NegateEffect(ev) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否破坏对方场上的卡？"
		-- 向玩家显示“请选择要破坏的卡”的提示信息，用于选择破坏对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 为选中的破坏对象播放选中动画，并记录这些卡被选为对象。
		Duel.HintSelection(sg)
		-- 中断当前效果处理，使后续的破坏处理与前段的无效处理不在同一时点，避免错误的连锁时点判定。
		Duel.BreakEffect()
		-- 将选择的那张对方场上的卡以卡片效果破坏并送去墓地。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
