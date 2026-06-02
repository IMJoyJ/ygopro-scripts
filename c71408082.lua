--黒竜の聖騎士
-- 效果：
-- 「黑龙降临」降临。「黑龙之圣骑士」的②的效果1回合只能使用1次。
-- ①：这张卡向守备表示怪兽攻击的伤害步骤开始时发动。那只怪兽破坏。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只「真红眼」怪兽特殊召唤。
function c71408082.initial_effect(c)
	-- 注册该卡记有「黑龙降临」卡名的关联关系
	aux.AddCodeList(c,18803791)
	c:EnableReviveLimit()
	-- ①：这张卡向守备表示怪兽攻击的伤害步骤开始时发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c71408082.descon)
	e1:SetTarget(c71408082.destg)
	e1:SetOperation(c71408082.desop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从手卡·卡组把1只「真红眼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,71408082)
	e2:SetCost(c71408082.spcost)
	e2:SetTarget(c71408082.sptg)
	e2:SetOperation(c71408082.spop)
	c:RegisterEffect(e2)
end
-- 伤害步骤开始时自身向守备表示怪兽攻击的发动条件判断函数
function c71408082.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为被攻击目标的怪兽
	local tc=Duel.GetAttackTarget()
	return tc and tc~=c and tc:IsDefensePos()
end
-- ①效果的发动可行性检查函数（Target）
function c71408082.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取作为被攻击目标的怪兽
	local tc=Duel.GetAttackTarget()
	-- 设置当前效果包含破坏作为攻击目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- ①效果的结算操作函数（Operation）
function c71408082.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为被攻击目标的怪兽
	local tc=Duel.GetAttackTarget()
	if tc:IsRelateToBattle() then
		-- 将选中的守备表示怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动代价函数，检查并执行解放自身
function c71408082.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤手卡·卡组中能被特殊召唤的「真红眼」怪兽的过滤条件
function c71408082.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动可行性检查函数（Target）
function c71408082.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查若自身解放后，场上的怪兽区域是否有可放置特殊召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在可以特殊召唤的「真红眼」怪兽
		and Duel.IsExistingMatchingCard(c71408082.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前效果包含从手卡或卡组中特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②效果的结算操作函数（Operation）
function c71408082.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上已无怪兽区域空格，结算终止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己手卡或卡组中1张符合过滤条件的「真红眼」怪兽
	local g=Duel.SelectMatchingCard(tp,c71408082.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
