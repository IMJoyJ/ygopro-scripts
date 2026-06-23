--リブロマンサー・ライジング
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以把同名卡不在自己场上存在的1只「书灵师」怪兽从卡组加入手卡。
-- ②：自己主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「书灵师」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册卡牌的两个效果：①发动时将符合条件的怪兽加入手牌；②主要阶段可发动的仪式召唤效果
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以把同名卡不在自己场上存在的1只「书灵师」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- 为仪式魔法卡注册等级合计条件的仪式召唤程序
	local e2=aux.AddRitualProcGreater2(c,s.ritfilter,LOCATION_HAND,nil,nil,true)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	c:RegisterEffect(e2)
end
-- 筛选「书灵师」怪兽的函数
function s.ritfilter(c)
	return c:IsSetCard(0x17c)
end
-- 用于检查场上是否存在同名卡的函数
function s.d2hmatchfilter(c,cd)
	return c:IsFaceup() and c:IsCode(cd)
end
-- 筛选可加入手牌的「书灵师」怪兽的函数
function s.d2hfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x17c) and c:IsAbleToHand()
		-- 确保所选怪兽在场上没有同名卡存在
		and not Duel.IsExistingMatchingCard(s.d2hmatchfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- 发动效果时处理从卡组检索并加入手牌的逻辑
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「书灵师」怪兽组
	local g=Duel.GetMatchingGroup(s.d2hfilter,tp,LOCATION_DECK,0,nil,tp)
	-- 判断是否有符合条件的怪兽且玩家选择发动效果
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组把「书灵师」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
