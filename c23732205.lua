--デリンジャラス・ドラゴン
-- 效果：
-- 龙族·暗属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方结束阶段，以这个回合没有攻击宣言的对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
-- ②：这张卡在墓地存在的状态，自己场上有「弹丸」怪兽特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c23732205.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只满足mfilter的怪兽（即龙族·暗属性怪兽）作为连接素材。
	aux.AddLinkProcedure(c,c23732205.mfilter,2)
	c:EnableReviveLimit()
	-- 给这张卡注册一个“已在墓地”的标记检测效果，返回的e0用于记录状态，防止②效果在同一连锁中重复进行不合法判定。
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
-- 连接素材过滤函数：判断素材怪兽是否为龙族且暗属性（通过连接素材专用种族/属性判定）。
function c23732205.mfilter(c)
	return c:IsLinkRace(RACE_DRAGON) and c:IsLinkAttribute(ATTRIBUTE_DARK)
end
-- ①效果的发动条件：当前不是自己的回合，即在对方结束阶段才能发动。
function c23732205.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回本卡控制者不是当前回合玩家，用于限定对方结束阶段。
	return tp~=Duel.GetTurnPlayer()
end
-- 对象过滤函数：选择攻击表示且本回合未进行过攻击宣言的怪兽。
function c23732205.desfilter(c)
	return c:IsAttackPos() and c:GetAttackAnnouncedCount()==0
end
-- ①效果的目标选择与发动判定：从对方场上选择1只攻击表示且本回合未攻击宣言的怪兽为对象，并记录其原本攻击力，设置破坏与伤害的操作信息。
function c23732205.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c23732205.desfilter(chkc) end
	-- 发动时检查对方场上是否存在至少1只满足条件的可选对象。
	if chk==0 then return Duel.IsExistingTarget(c23732205.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从对方场上选择1只满足条件的攻击表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c23732205.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetBaseAttack()
	if atk<0 then atk=0 end
	-- 设置操作信息：将选择的对象怪兽破坏（1张）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：将对对方造成原本攻击力数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- ①效果处理：取得对象怪兽，若仍与效果关联则将其破坏，破坏成功后给予对方其原本攻击力数值的伤害。
function c23732205.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 用效果破坏对象怪兽；若实际破坏成功则继续执行伤害。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给与对方玩家对象怪兽原本攻击力数值的伤害。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
-- ②效果的触发过滤：判定特殊召唤成功的怪兽是否为表侧表示、我方控制的「弹丸」怪兽，且其特殊召唤的诱发效果不是se（se为nil时不作排除）。
function c23732205.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x102)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果的触发条件：本次特殊召唤成功的怪兽中存在满足cfilter的「弹丸」怪兽，即我方场上有「弹丸」怪兽被特殊召唤（并排除自身②效果导致的特殊召唤）。
function c23732205.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c23732205.cfilter,1,nil,tp,se)
end
-- ②效果发动前确认：自己主要怪兽区有可用空格，且墓地的这张卡能够被特殊召唤。
function c23732205.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：即将将墓地的这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其特殊召唤到我方场上；特殊召唤成功后，给它附加离场时改为除外的效果。
function c23732205.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与效果相关且特殊召唤成功（以表侧表示特殊召唤到我方主要怪兽区），成功后才附加除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
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
