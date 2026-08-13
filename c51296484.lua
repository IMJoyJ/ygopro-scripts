--粛声の竜賢姫サフィラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张仪式魔法卡送去墓地。那之后，可以把1只战士族·龙族而光属性的仪式怪兽从自己的卡组·墓地加入手卡。
-- ②：把墓地的这张卡除外才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只战士族·龙族而光属性的仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 初始化并注册该卡的两个效果：①为手牌起动效果，丢弃自身从卡组把1张仪式魔法卡送去墓地，之后可将战士族·龙族·光属性的仪式怪兽从自己的卡组·墓地加入手卡；②为墓地起动效果，除外自身并进行战士族·龙族·光属性仪式怪兽的仪式召唤。
function s.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张仪式魔法卡送去墓地。那之后，可以把1只战士族·龙族而光属性的仪式怪兽从自己的卡组·墓地加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tscost)
	e1:SetTarget(s.tstg)
	e1:SetOperation(s.tsop)
	c:RegisterEffect(e1)
	-- 调用公共仪式召唤辅助函数，为②构建一个仪式召唤效果：以手卡为仪式怪兽来源，允许等级合计大于等于仪式怪兽等级，过滤条件为s.filter，先不注册以便后续自定义设置。
	local e2=aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,nil,true)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置该仪式召唤效果（②）的发动代价为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
-- 定义①的代价函数：从手卡丢弃这张卡作为发动代价；在合法性检查时确认该卡可以丢弃，实际处理时将其以代价+丢弃的理由送入墓地。
function s.tscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 以“代价+丢弃”的理由将这张卡从手卡送去墓地，作为①的发动代价。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 定义从卡组选择仪式魔法卡送去墓地的过滤条件：该卡同时是仪式类型和魔法类型，并且可以送去墓地。
function s.tsfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
-- 定义①的发动目标：检查卡组中是否存在可送去墓地的仪式魔法卡；若存在则设定操作信息，表示效果处理时会将1张卡从卡组送去墓地。
function s.tstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认自己卡组中是否存在至少1张满足条件的仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tsfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：本次效果处理会把1张卡从卡组送去墓地（不取对象、数量1、玩家为tp），供连锁响应检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义可加入手卡的仪式怪兽过滤条件：必须是战士族或龙族、光属性、仪式怪兽，并且可以被加入手卡。
function s.thfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_WARRIOR) and c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- ①的效果处理：先从卡组选1张仪式魔法卡送去墓地；若送墓成功且自己卡组·墓地存在可加入手卡的仪式怪兽，则询问玩家是否加入手卡；选择是时中断效果处理，让玩家从卡组或墓地选1只符合条件的仪式怪兽加入手卡并向对方展示。
function s.tsop(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 弹出选择提示消息，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组中选择1张满足条件的仪式魔法卡（用于送去墓地）。
	local g=Duel.SelectMatchingCard(tp,s.tsfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断条件：选择的卡存在且送入墓地成功，且该卡确实在墓地（未被其他效果移动），满足后才继续执行后续可选检索。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 检查自己卡组或墓地是否存在至少1只满足条件的仪式怪兽，且该怪兽不受王家长眠之谷等不能移动的效果影响。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil)
		-- 让玩家选择是否将仪式怪兽加入手卡；选择“是”才继续执行加入手卡的处理。
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把仪式怪兽加入手卡？"
		-- 中断当前效果处理，使后续加入手卡的处理与之前的送墓处理在不同时点进行，避免错过时点。
		Duel.BreakEffect()
		-- 弹出选择提示消息，提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从自己的墓地或卡组中选择1只满足条件的仪式怪兽（不受王谷影响）加入手卡。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
		-- 将选择的仪式怪兽以效果理由加入其持有者的手卡（玩家参数为nil表示加入原本持有者手卡）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的仪式怪兽卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 定义②仪式召唤可选择的仪式怪兽过滤条件：必须是战士族或龙族、光属性、仪式怪兽；当chk参数为真时额外排除效果持有者自身（该卡）。
function s.filter(c,e,tp,chk)
	return c:IsRace(RACE_DRAGON+RACE_WARRIOR) and c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_LIGHT) and (not chk or c~=e:GetHandler())
end
