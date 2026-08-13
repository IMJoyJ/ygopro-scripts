--ミズティックコール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，从手卡丢弃1只其他的魔法师族怪兽或1张魔法·陷阱卡才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只魔法师族·4星怪兽除外。这个回合的结束阶段，除外的那只怪兽加入手卡或特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（手卡·墓地的起动效果，支付代价后特殊召唤这张卡并赋予离场除外效果）、②效果（召唤·特殊召唤成功的场合发动的诱发效果）以及②效果的特殊召唤成功时版本
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，从手卡丢弃1只其他的魔法师族怪兽或1张魔法·陷阱卡才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只魔法师族·4星怪兽除外。这个回合的结束阶段，除外的那只怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外效果"
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
-- 代价过滤函数：可以被丢弃的魔法师族怪兽或魔法·陷阱卡
function s.cfilter(c)
	return c:IsDiscardable() and (c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsRace(RACE_SPELLCASTER))
end
-- ①效果的发动代价：确认手卡存在满足条件的卡，然后丢弃1只其他的魔法师族怪兽或1张魔法·陷阱卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1张满足代价条件且不是这张卡自身的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家从手卡选择并丢弃1张满足条件的卡作为发动代价
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①效果的对象设定：确认自己主要怪兽区有空位且这张卡可以特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否有可用空格且这张卡能够被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：这个效果将对这张卡自身进行1次特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：将这张卡特殊召唤，并赋予它从场上离开的场合除外的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与连锁关联且不受王家长眠之谷影响，则将其以表侧表示特殊召唤，成功时执行后续处理
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤函数：可以被除外的魔法师族·4星怪兽
function s.thfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove()
end
-- ②效果的对象设定：确认卡组存在魔法师族·4星怪兽，并设置从卡组除外的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1只魔法师族·4星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：这个效果将从卡组把1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组把1只魔法师族·4星怪兽除外，并注册在这个回合的结束阶段将那只怪兽加入手卡或特殊召唤的处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送提示消息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从卡组选择1只魔法师族·4星怪兽作为除外对象
	local rc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	local fid=c:GetFieldID()
	-- 将选中的怪兽以表侧表示除外（效果原因），除外成功则继续处理
	if rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 then
		rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))  --"「秘召水巫女士」的效果除外"
		-- 这个回合的结束阶段，除外的那只怪兽加入手卡或特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rc)
		e1:SetLabel(fid)
		e1:SetCondition(s.thcon2)
		e1:SetOperation(s.thop2)
		-- 把结束阶段处理用的持续效果注册为玩家自己的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段处理的条件：确认除外的那只怪兽仍是本次效果除外的对象（通过效果标记识别）
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(id)==fid
end
-- 结束阶段的处理：确认对象有效后，将除外的那只怪兽加入手卡或特殊召唤
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家显示卡片发动动画，提示「秘召水巫女士」的效果处理开始
	Duel.Hint(HINT_CARD,0,id)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==fid then
		-- 检查那只怪兽能否被特殊召唤且自己主要怪兽区有可用空格
		local spchk=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 若那只怪兽可以加入手卡，且不能特殊召唤或玩家选择了加入手卡，则执行加入手卡的处理
		if tc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
			-- 把除外的那只怪兽加入持有者的手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的那只怪兽
			Duel.ConfirmCards(1-tp,tc)
		elseif spchk then
			-- 将除外的那只怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
