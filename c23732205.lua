--デリンジャラス・ドラゴン
-- 效果：
-- 龙族·暗属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方结束阶段，以这个回合没有攻击宣言的对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
-- ②：这张卡在墓地存在的状态，自己场上有「弹丸」怪兽特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c23732205.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2个满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c23732205.mfilter,2)
	c:EnableReviveLimit()
	-- 注册一个监听送入墓地事件的单次持续效果，用于记录卡片是否已进入墓地
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：对方结束阶段，以这个回合没有攻击宣言的对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23732205,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1,23732205)
	e1:SetCondition(c23732205.descon)
	e1:SetTarget(c23732205.destg)
	e1:SetOperation(c23732205.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上有「弹丸」怪兽特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23732205,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,23732206)
	e2:SetLabelObject(e0)
	e2:SetCondition(c23732205.spcon)
	e2:SetTarget(c23732205.sptg)
	e2:SetOperation(c23732205.spop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤器，筛选龙族且暗属性的怪兽
function c23732205.mfilter(c)
	return c:IsLinkRace(RACE_DRAGON) and c:IsLinkAttribute(ATTRIBUTE_DARK)
end
-- 效果条件函数，判断是否为对方回合
function c23732205.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return tp~=Duel.GetTurnPlayer()
end
-- 破坏效果的目标过滤器，筛选攻击表示且未攻击宣言的怪兽
function c23732205.desfilter(c)
	return c:IsAttackPos() and c:GetAttackAnnouncedCount()==0
end
-- 设置破坏和伤害效果的目标选择逻辑，选择对方场上未攻击宣言的攻击表示怪兽
function c23732205.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c23732205.desfilter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c23732205.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c23732205.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetBaseAttack()
	if atk<0 then atk=0 end
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 执行破坏和伤害效果，对目标怪兽进行破坏并造成等同于其攻击力的伤害
function c23732205.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 执行破坏操作，若成功则继续造成伤害
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 对对方造成等同于目标怪兽攻击力的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
-- 特殊召唤条件的过滤器，筛选己方场上表侧表示的「弹丸」怪兽
function c23732205.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x102)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 判断是否满足特殊召唤条件，即己方场上有「弹丸」怪兽被特殊召唤
function c23732205.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c23732205.cfilter,1,nil,tp,se)
end
-- 设置特殊召唤效果的目标选择逻辑，检查是否有足够的召唤位置和特殊召唤条件
function c23732205.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将卡片特殊召唤到场上并设置其离开场上的处理
function c23732205.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否能被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置卡片离开场上时的处理，使其被移除而非送入墓地
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
