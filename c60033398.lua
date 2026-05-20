--戦華の来－張遠
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己的「战华」怪兽和对方的表侧表示怪兽进行战斗的伤害步骤开始时才能发动。这张卡从手卡特殊召唤，那只对方怪兽的攻击力下降1000。
-- ②：这张卡以外的自己的「战华」怪兽不会被战斗破坏。
-- ③：对方场上的卡被战斗·效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
function c60033398.initial_effect(c)
	-- ①：自己的「战华」怪兽和对方的表侧表示怪兽进行战斗的伤害步骤开始时才能发动。这张卡从手卡特殊召唤，那只对方怪兽的攻击力下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60033398,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,60033398)
	e1:SetCondition(c60033398.spcon)
	e1:SetTarget(c60033398.sptg)
	e1:SetOperation(c60033398.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的自己的「战华」怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c60033398.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：对方场上的卡被战斗·效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60033398,1))  --"卡片破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,60033399)
	e3:SetCondition(c60033398.descon)
	e3:SetTarget(c60033398.destg)
	e3:SetOperation(c60033398.desop)
	c:RegisterEffect(e3)
end
-- ①号效果的发动条件判定：自己的「战华」怪兽与对方表侧表示怪兽进行战斗的伤害步骤开始时
function c60033398.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行战斗的攻击怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if not d then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	e:SetLabelObject(d)
	return a:IsFaceup() and a:IsControler(tp) and a:IsSetCard(0x137) and d:IsFaceup() and d:IsControler(1-tp)
end
-- ①号效果的发动准备：检查自身是否能从手卡特殊召唤
function c60033398.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的处理：将这张卡特殊召唤，并使进行战斗的对方怪兽攻击力下降1000
function c60033398.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=e:GetLabelObject()
		if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(1-tp) then
			-- 那只对方怪兽的攻击力下降1000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- ②号效果的适用对象过滤：这张卡以外的自己的「战华」怪兽
function c60033398.indtg(e,c)
	return c:IsSetCard(0x137) and c~=e:GetHandler()
end
-- 过滤出因战斗或效果破坏的对方场上的卡
function c60033398.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③号效果的发动条件判定：对方场上的卡被战斗·效果破坏的场合
function c60033398.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c60033398.cfilter,1,nil,tp)
end
-- ③号效果的发动准备：选择对方场上1张卡作为破坏对象
function c60033398.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 在发动检查阶段，确认对方场上是否存在可以作为对象破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向发动效果的玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理的操作信息为破坏所选的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③号效果的处理：破坏作为对象的卡
function c60033398.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为破坏对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
