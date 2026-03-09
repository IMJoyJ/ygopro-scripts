--ドリル・アームド・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只风属性怪兽送去墓地才能发动。这个回合中，自己场上的龙族·风属性怪兽的攻击力上升300。
-- ②：从自己墓地把风属性或7星以上的龙族怪兽任意数量除外才能发动。把持有和除外的怪兽数量相同等级的1只「钻头武装龙」以外的龙族怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 注册两个效果，分别是攻击力上升效果和检索效果
function s.initial_effect(c)
	-- ①：从手卡把这张卡和1只风属性怪兽送去墓地才能发动。这个回合中，自己场上的龙族·风属性怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把风属性或7星以上的龙族怪兽任意数量除外才能发动。把持有和除外的怪兽数量相同等级的1只「钻头武装龙」以外的龙族怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手牌中是否包含风属性且能送入墓地的怪兽
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToGraveAsCost()
end
-- 判断是否满足发动条件：手牌中有这张卡和至少一只风属性怪兽
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and
		-- 检查手牌中是否存在符合条件的风属性怪兽
		Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择符合条件的风属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡送入墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置并注册攻击力上升效果
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置并注册攻击力上升效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(300)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击力上升效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 判断目标怪兽是否为龙族且风属性
function s.atktg(e,c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤函数，用于筛选墓地中符合条件的龙族怪兽（7星以上或风属性）
function s.cfilter(c)
	return c:IsRace(RACE_DRAGON) and (c:IsLevelAbove(7) or c:IsAttribute(ATTRIBUTE_WIND)) and c:IsAbleToRemoveAsCost()
end
-- 辅助函数，用于检查所选怪兽数量是否能匹配卡组中怪兽等级
function s.fselect(g,tg)
	return tg:IsExists(Card.IsLevel,1,nil,#g)
end
-- 过滤函数，用于筛选卡组中符合条件的龙族怪兽（非本卡且等级大于等于1）
function s.thfilter(c)
	return not c:IsCode(id) and c:IsLevelAbove(1) and c:IsRace(RACE_DRAGON)
		and c:IsAbleToHand()
end
-- 设置检索效果的发动条件和处理流程
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取墓地中所有符合条件的龙族怪兽
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取卡组中所有符合条件的龙族怪兽
	local tg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local _,maxlv=tg:GetMaxGroup(Card.GetLevel)
	if chk==0 then
		if not e:IsCostChecked() then return false end
		return cg:CheckSubGroup(s.fselect,1,maxlv,tg)
	end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:SelectSubGroup(tp,s.fselect,false,1,maxlv,tg)
	-- 将选中的怪兽除外作为代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetCount())
	-- 设置操作信息，表示将从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选卡组中等级与除外怪兽数量相同的龙族怪兽（非本卡）
function s.thfilter2(c,lv)
	return not c:IsCode(id) and c:IsLevel(lv) and c:IsRace(RACE_DRAGON)
		and c:IsAbleToHand()
end
-- 处理检索效果的发动和实现
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 根据除外数量选择对应等级的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
