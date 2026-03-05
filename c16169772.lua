--インスタント・コンタクト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付1000基本分才能发动。7星以下的1只「元素英雄」怪兽或者「新空间侠」怪兽无视召唤条件从额外卡组特殊召唤。自己的场上以及墓地没有「元素英雄 新宇侠」存在的场合，这个效果特殊召唤的怪兽不能攻击，效果无效化，结束阶段回到持有者的额外卡组。
local s,id,o=GetID()
-- 初始化卡片效果，设置发动条件、支付费用、目标选择和效果处理函数
function s.initial_effect(c)
	-- 记录该卡的额外卡名（元素英雄新宇侠）
	aux.AddCodeList(c,89943723)
	-- 设置该卡为「元素英雄」系列怪兽
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：支付1000基本分才能发动。7星以下的1只「元素英雄」怪兽或者「新空间侠」怪兽无视召唤条件从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 支付1000基本分的费用处理函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 筛选满足特殊召唤条件的怪兽（7星以下、元素英雄或新空间侠系列、有召唤空位、可特殊召唤）
function s.spfilter(c,e,tp)
	return (c:IsLevelBelow(7) and c:IsSetCard(0x3008) or c:IsSetCard(0x1f))
		-- 检查额外卡组是否有满足条件的怪兽召唤空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置特殊召唤效果的目标选择函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 检查场上或墓地是否存在元素英雄新宇侠
function s.cfilter(c)
	return c:IsCode(89943723) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 执行特殊召唤效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	-- 尝试特殊召唤选定的怪兽
	if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
		-- 若场上或墓地没有元素英雄新宇侠，则施加限制效果
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) then
		local c=e:GetHandler()
		-- 特殊召唤的怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3,true)
		-- 结束阶段将怪兽送回额外卡组
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetLabelObject(tc)
		e4:SetCondition(s.tdcon)
		e4:SetOperation(s.tdop)
		-- 注册结束阶段送回额外卡组的效果
		Duel.RegisterEffect(e4,tp)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断结束阶段效果是否触发的条件函数
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or tc:GetFlagEffect(id)==0 then
		e:Reset()
		return false
	end
	return true
end
-- 结束阶段将怪兽送回额外卡组的效果处理函数
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc then
		-- 将怪兽送回额外卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
