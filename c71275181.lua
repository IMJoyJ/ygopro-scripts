--２つに１つ
-- 效果：
-- ①：把1只怪兽和2张陷阱卡从卡组给对方观看，对方从那之中随机选1张。自己把剩下的卡确认，那之内的1张陷阱卡除外。那之后，对方从以下选1个，自己让那个效果适用。
-- ●对方选的卡给双方确认，怪兽的场合，加入手卡或特殊召唤。不是的场合，除外。剩余回到卡组。
-- ●对方没选的卡之内没除外的卡给双方确认，怪兽的场合，加入手卡。不是的场合，除外。剩余回到卡组。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：把1只怪兽和2张陷阱卡从卡组给对方观看，对方从那之中随机选1张。自己把剩下的卡确认，那之内的1张陷阱卡除外。那之后，对方从以下选1个，自己让那个效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可以被除外的怪兽或陷阱卡
function s.chkfilter(c)
	return c:IsType(TYPE_MONSTER+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 过滤可以加入手卡或在满足怪兽区域空位时特殊召唤的怪兽卡
function s.chkfilter2(c,e,tp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))) and c:IsType(TYPE_MONSTER)
end
-- 检查选出的卡片组中是否包含至少2张陷阱卡和1张满足条件的怪兽卡
function s.fslect(g,e,tp)
	return g:IsExists(Card.IsType,2,nil,TYPE_TRAP) and g:IsExists(s.chkfilter2,1,nil,e,tp)
end
-- 效果发动的对象选择与可行性检查（检查卡组中是否存在满足条件的3张卡）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有满足条件的怪兽和陷阱卡
	local g=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckSubGroup(s.fslect,3,3,e,tp) end
end
-- 效果处理的执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取卡组中所有满足条件的怪兽和陷阱卡
	local g=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_DECK,0,nil)
	if not g:CheckSubGroup(s.fslect,3,3,e,tp) then return end
	local sg=g:SelectSubGroup(tp,s.fslect,false,3,3,e,tp)
	if not sg then return end
	-- 将选出的3张卡（1只怪兽和2张陷阱卡）给对方观看
	Duel.ConfirmCards(1-tp,sg)
	local tc1=sg:RandomSelect(1-tp,1):GetFirst()
	local tg=sg-tc1
	-- 自己确认对方没有选的剩下2张卡
	Duel.ConfirmCards(tp,tg)
	local tc2=tg:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_TRAP)
	local fg=tg-tc2
	local tc3=fg:GetFirst()
	-- 如果成功将剩下的那张陷阱卡除外
	if Duel.Remove(tc2,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 产生时点中断，用于连接“那之后”的效果处理
		Duel.BreakEffect()
		-- 让对方从“把选的卡确认”和“把没有选的卡确认”中选择1个适用
		local op=aux.SelectFromOptions(1-tp,
			{true,aux.Stringid(id,1),1},  --"把选的卡确认"
			{true,aux.Stringid(id,2),2})  --"把没有选的卡确认"
		if op==1 then
			-- 自己确认对方选的那张卡
			Duel.ConfirmCards(tp,tc1)
			-- 对方确认自己选的那张卡（使之成为双方确认状态）
			Duel.ConfirmCards(1-tp,tc1)
			if tc1:IsType(TYPE_MONSTER) then
				-- 获取自己场上可用的怪兽区域数量
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local spchk=tc1:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0
				-- 如果该卡可以加入手卡，且（不能特殊召唤或玩家选择加入手卡）
				if tc1:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
					-- 将对方选的怪兽卡加入自己手卡
					Duel.SendtoHand(tc1,nil,REASON_EFFECT)
					-- 给对方确认加入手卡的卡片
					Duel.ConfirmCards(1-tp,tc1)
				elseif spchk then
					-- 将对方选的怪兽卡在自己场上特殊召唤
					Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)
				end
			else
				-- 将对方选的非怪兽卡（陷阱卡）除外
				Duel.Remove(tc1,POS_FACEUP,REASON_EFFECT)
			end
		elseif op==2 then
			-- 自己确认对方没选且没除外的那张卡
			Duel.ConfirmCards(tp,tc3)
			-- 对方确认其没选且没除外的那张卡（使之成为双方确认状态）
			Duel.ConfirmCards(1-tp,tc3)
			if tc3:IsType(TYPE_MONSTER) then
				if tc3:IsAbleToHand() then
					-- 将对方没选且没除外的怪兽卡加入自己手卡
					Duel.SendtoHand(tc3,nil,REASON_EFFECT)
					-- 给对方确认加入手卡的卡片
					Duel.ConfirmCards(1-tp,tc3)
				else
					-- 无法加入手卡时，根据规则将该卡送去墓地
					Duel.SendtoGrave(tc3,REASON_RULE)
				end
			else
				-- 将对方没选且没除外的非怪兽卡（陷阱卡）除外
				Duel.Remove(tc3,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
	-- 将卡组中剩余的卡洗切（剩余回到卡组）
	Duel.ShuffleDeck(tp)
end
