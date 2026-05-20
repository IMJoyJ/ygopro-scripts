--ヴァルモニカ・イントナーレ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从以下效果选1个适用。自己的灵摆区域没有「异响鸣」卡存在的场合，适用的效果由对方来选。
-- ●自己回复500基本分。可以特殊召唤的怪兽在自己墓地存在的场合，再让那之内的1只由对方选出，那只怪兽在自己场上特殊召唤。
-- ●自己受到500伤害。那之后，可以从自己墓地把1只4星怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片发动时的效果，设置分类、类型、时点、一回合一次的限制以及效果处理函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从以下效果选1个适用。自己的灵摆区域没有「异响鸣」卡存在的场合，适用的效果由对方来选。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 用于筛选自己墓地中可以特殊召唤的怪兽的过滤函数
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 用于筛选自己墓地中4星且能加入手卡的怪兽的过滤函数
function s.hfilter(c)
	return c:IsLevel(4) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理，根据灵摆区是否有「异响鸣」卡决定由谁选择效果，并执行对应的分支效果
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil then
		-- 检查自己灵摆区域是否存在「异响鸣」卡，若存在则由自己（tp）选择，否则由对方（1-tp）选择
		local p=Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,0x1a3) and tp or 1-tp
		op=aux.SelectFromOptions(p,{true,aux.Stringid(id,1)},{true,aux.Stringid(id,2)})  --"自己回复500基本分/自己受到500伤害"
	end
	if op==1 then
		-- 自己回复500基本分，若实际回复量小于1则不进行后续处理
		if Duel.Recover(tp,500,REASON_EFFECT)<1 then return end
		-- 让对方玩家从自己墓地选择1只可以特殊召唤的怪兽
		local g=Duel.SelectMatchingCard(1-tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			-- 中断当前效果，使后续的特殊召唤与回复基本分不视为同时进行
			Duel.BreakEffect()
			-- 将选出的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	-- 自己受到500伤害，若实际受到伤害则继续处理后续效果
	elseif Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 获取自己墓地中所有满足条件的4星怪兽（适用王家之谷的过滤）
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.hfilter),tp,LOCATION_GRAVE,0,nil)
		-- 若墓地存在符合条件的怪兽，询问玩家是否将1只4星怪兽加入手卡
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否从墓地把4星怪兽加入手卡？"
			-- 提示玩家选择要加入手牌的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果，使后续的加入手卡与受到伤害不视为同时进行
			Duel.BreakEffect()
			-- 将选中的怪兽加入玩家手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
