--エクシーズ・インポート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只超量怪兽和持有那个攻击力以下的攻击力的对方场上1只怪兽为对象才能发动。那只对方怪兽在那只自己怪兽下面重叠作为超量素材。
function c14602126.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,14602126+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14602126.target)
	e1:SetOperation(c14602126.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检索满足条件的超量怪兽
function c14602126.xyzfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 效果作用：检查对方场上是否存在攻击力不超过该超量怪兽攻击力的怪兽
		and Duel.IsExistingTarget(c14602126.matfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 效果作用：定义超量素材筛选条件
function c14602126.matfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsCanOverlay()
end
-- 效果作用：设置效果的目标选择函数
function c14602126.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果作用：判断是否满足发动条件
	if chk==0 then return Duel.IsExistingTarget(c14602126.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 效果作用：提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 效果作用：选择满足条件的超量怪兽
	local g=Duel.SelectTarget(tp,c14602126.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	-- 效果作用：提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 效果作用：选择满足条件的对方怪兽作为超量素材
	Duel.SelectTarget(tp,c14602126.matfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
end
-- 效果作用：设置效果的发动处理函数
function c14602126.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 效果作用：获取当前连锁中的目标卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and not tc:IsImmuneToEffect(e) and lc:IsRelateToEffect(e) and lc:IsControler(1-tp) and lc:IsType(TYPE_MONSTER) and not lc:IsImmuneToEffect(e) then
		local og=lc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 效果作用：将目标怪兽的叠放卡片送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 效果作用：将目标怪兽叠放至超量怪兽下方作为超量素材
		Duel.Overlay(tc,Group.FromCards(lc))
	end
end
