--時械神祖ヴルガータ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：从额外卡组特殊召唤的这张卡进行战斗的伤害步骤结束时才能发动。对方场上的怪兽全部除外。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成一半。
-- ③：这张卡的②的效果发动的回合的结束阶段发动。那个效果由自己来除外的怪兽尽可能在对方场上特殊召唤。
function c67508932.initial_effect(c)
	-- 为这张卡添加同调召唤手续（素材为：调整＋调整以外的怪兽1只以上）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
	-- ②：从额外卡组特殊召唤的这张卡进行战斗的伤害步骤结束时才能发动。对方场上的怪兽全部除外。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成一半。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67508932,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(c67508932.rmcond)
	e4:SetTarget(c67508932.rmtg)
	e4:SetOperation(c67508932.rmop)
	c:RegisterEffect(e4)
	-- ③：这张卡的②的效果发动的回合的结束阶段发动。那个效果由自己来除外的怪兽尽可能在对方场上特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(67508932,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c67508932.spcon)
	e5:SetTarget(c67508932.sptg)
	e5:SetOperation(c67508932.spop)
	c:RegisterEffect(e5)
end
-- 定义效果②的发动条件函数。
function c67508932.rmcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否在伤害步骤结束时、这张卡是从额外卡组特殊召唤的、且本回合进行过战斗。
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and c:IsSummonLocation(LOCATION_EXTRA) and c:GetBattledGroupCount()>0
end
-- 定义效果②的靶向与发动准备函数。
function c67508932.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只可以被除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以被除外的怪兽组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁处理的操作信息，表示将除外对方场上的这些怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,1-tp,LOCATION_MZONE)
end
-- 过滤函数：筛选出没有因转移去向效果（如大宇宙）而未正常除外的卡片。
function c67508932.rfilter(c)
	return not c:IsReason(REASON_REDIRECT)
end
-- 定义效果②的执行逻辑函数。
function c67508932.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有可以被除外的怪兽组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 将这些怪兽表侧表示除外，并判断是否成功除外了至少1张卡。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		-- 获取本次操作实际被除外的卡片组。
		local og=Duel.GetOperatedGroup()
		local rg=og:Filter(c67508932.rfilter,nil)
		if #rg>0 then
			local lab=0
			if c:GetFlagEffect(67508933)==0 then
				lab=c:GetFieldID()
				c:RegisterFlagEffect(67508933,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,lab)
			else
				lab=c:GetFlagEffectLabel(67508933)
			end
			-- 遍历所有被正常除外的卡片。
			for oc in aux.Next(rg) do
				oc:RegisterFlagEffect(67508932,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,lab)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时对方受到的战斗伤害变成一半。③：这张卡的②的效果发动的回合的结束阶段发动。那个效果由自己来除外的怪兽尽可能在对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册“直到回合结束时对方受到的战斗伤害变成一半”的全局效果。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：筛选出被该卡效果②除外、且可以被特殊召唤到对方场上的怪兽。
function c67508932.spfilter(c,e,tp)
	local lab=c:GetFlagEffectLabel(67508932)
	return lab and lab==e:GetHandler():GetFlagEffectLabel(67508933)
		and c:GetReasonPlayer()==tp
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 定义效果③的发动条件函数（检查本回合是否发动过效果②）。
function c67508932.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(67508933)>0
end
-- 定义效果③的靶向与发动准备函数。
function c67508932.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取所有满足特殊召唤条件的被除外怪兽组。
	local g=Duel.GetMatchingGroup(c67508932.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e,tp)
	-- 设置连锁处理的操作信息，表示将特殊召唤这些被除外的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,LOCATION_REMOVED)
end
-- 定义效果③的执行逻辑函数。
function c67508932.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	-- 获取所有满足特殊召唤条件的被除外怪兽组。
	local tg=Duel.GetMatchingGroup(c67508932.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e,tp)
	if ft<=0 or #tg==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=tg:Select(tp,ft,ft,nil)
	if #g>0 then
		-- 将选中的怪兽尽可能以表侧表示特殊召唤到对方场上。
		Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
