--アルカナフォースⅦ－THE CHARIOT
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：这张卡战斗破坏对方怪兽的场合，可以把那只怪兽在自己场上特殊召唤。
-- ●里：这张卡的控制权转移给对方。
function c34568403.initial_effect(c)
	-- 诱发必发效果，对应一速的【……发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34568403,0))  --"投掷硬币"
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	-- 设置硬币投掷操作的信息
	e1:SetTarget(aux.ArcanaCoinTarget)
	e1:SetOperation(c34568403.coinop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34568403,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(c34568403.spcon)
	e4:SetTarget(c34568403.sptg)
	e4:SetOperation(c34568403.spop)
	c:RegisterEffect(e4)
end
-- 投掷硬币并根据结果执行控制权转移或特殊召唤
function c34568403.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=0
	local toss=false
	-- 判断玩家是否受到效果影响
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 通过选择选项模拟硬币投掷结果
		res=1-Duel.SelectOption(tp,60,61)
	else
		-- 进行一次硬币投掷操作
		res=Duel.TossCoin(tp,1)
		toss=true
	end
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if toss then
		c:RegisterFlagEffect(FLAG_ID_REVERSAL_OF_FATE,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	c:RegisterFlagEffect(FLAG_ID_ARCANA_COIN,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,res,63-res)
	if res==0 then
		-- 将控制权转移给对方玩家
		Duel.GetControl(c,1-tp)
	end
end
-- 判断是否满足特殊召唤条件
function c34568403.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1 and c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 设置特殊召唤目标及操作信息
function c34568403.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断目标怪兽是否在墓地或除外区且有召唤空间
		and ((tc:IsLocation(LOCATION_GRAVE) or tc:IsLocation(LOCATION_REMOVED) and tc:IsFaceup()) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 判断目标怪兽是否在额外卡组且有召唤空间
			or tc:IsLocation(LOCATION_EXTRA) and tc:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0) end
	-- 设置连锁处理的目标卡片
	Duel.SetTargetCard(tc)
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 执行特殊召唤操作
function c34568403.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
