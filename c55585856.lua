--ミズティックコール
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌·墓地特召效果、②召·特召成功除外卡组怪兽于结束阶段加手/特召效果
function s.initial_effect(c)
	-- ①：此卡在手牌·墓地存在的场合，从手牌丢弃1张魔法·陷阱卡或1只魔法师族怪兽才能发动。此卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：此卡召唤·特殊召唤成功的场合才能发动。从卡组把1只4星魔法师族怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- Cost过滤条件：手牌中可丢弃的魔法·陷阱卡或魔法师族怪兽
function s.cfilter(c)
	return c:IsDiscardable() and (c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsRace(RACE_SPELLCASTER))
end
-- ①效果发动Cost：丢弃1张魔法·陷阱卡或1只魔法师族怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：手牌是否存在除自身外可丢弃的魔法·陷阱卡或魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌丢弃1张满足条件的卡
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①效果发动准备：设置特殊召唤自身的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：主要怪兽区域有空位且自身可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：特殊召唤自身，并给予离场除外约束
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否关联连锁且不受王谷影响，成功特召后注册离场除外效果
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的此卡从场地离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 卡组过滤条件：4星的魔法师族怪兽且可除外
function s.thfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove()
end
-- ②效果发动准备：设置从卡组除外卡片的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在满足条件的4星魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组除外1只4星魔法师族怪兽，并注册结束阶段效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组选择1只满足条件的4星魔法师族怪兽
	local rc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	local fid=c:GetFieldID()
	-- 成功除外目标卡时，注册结束阶段的后续处理
	if rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 then
		rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))
		-- 结束阶段，选那张卡加入手牌或特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rc)
		e1:SetLabel(fid)
		e1:SetCondition(s.thcon2)
		e1:SetOperation(s.thop2)
		-- 注册延迟至结束阶段生效的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段效果条件检查：目标卡仍保持注册时的Flag标记
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(id)==fid
end
-- 结束阶段效果处理：选择将除外的卡加入手牌或特殊召唤
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动提示
	Duel.Hint(HINT_CARD,0,id)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==fid then
		-- 检查目标卡是否可特殊召唤且怪兽区域有空位
		local spchk=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断目标卡是否能加入手牌，若同时能特召则由玩家选择操作分支
		if tc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将目标卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,tc)
		elseif spchk then
			-- 将目标卡表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
