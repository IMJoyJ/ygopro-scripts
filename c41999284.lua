--リンクリボー
-- 效果：
-- 1星怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时，把这张卡解放才能发动。那只对方怪兽的攻击力直到回合结束时变成0。
-- ②：自己·对方回合，这张卡在墓地存在的场合，把自己场上1只1星怪兽解放才能发动。这张卡特殊召唤。
function c41999284.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，使用至少1个1星怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLevel,1),1)
	-- ①：对方怪兽的攻击宣言时，把这张卡解放才能发动。那只对方怪兽的攻击力直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c41999284.atkcon)
	e1:SetCost(c41999284.atkcost)
	e1:SetOperation(c41999284.atkop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，这张卡在墓地存在的场合，把自己场上1只1星怪兽解放才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,41999284)
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	e2:SetCost(c41999284.spcost)
	e2:SetTarget(c41999284.sptg)
	e2:SetOperation(c41999284.spop)
	c:RegisterEffect(e2)
end
-- 攻击宣言时的发动条件：对方怪兽攻击且不是我方回合
function c41999284.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽攻击且不是我方回合
	return tp~=Duel.GetTurnPlayer() and aux.nzatk(Duel.GetAttacker())
end
-- 效果发动时的解放费用：解放自己
function c41999284.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自己
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 攻击宣言时的效果处理：将对方攻击怪兽的攻击力变为0
function c41999284.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and tc:IsFaceup() then
		-- 将对方攻击怪兽的攻击力变为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 筛选场上可解放的1星怪兽的过滤函数
function c41999284.cfilter(c,tp)
	-- 满足条件的怪兽为1星且场上存在可用怪兽区
	return c:IsLevel(1) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤时的解放费用：选择并解放场上1只1星怪兽
function c41999284.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c41999284.cfilter,1,nil,tp) end
	-- 选择满足条件的1只怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c41999284.cfilter,1,1,nil,tp)
	-- 解放选择的怪兽
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤的发动条件：卡片可特殊召唤
function c41999284.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤的效果处理：将卡片特殊召唤到场上
function c41999284.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
