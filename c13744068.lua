--バーサーク・デーモン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以包含恶魔族怪兽的自己场上最多2只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽破坏。
-- ②：这张卡的①的效果破坏怪兽时，以那个数量的对方场上的表侧表示怪兽为对象才能发动。这张卡的攻击力直到下次的自己回合的结束时上升作为对象的怪兽的原本攻击力的合计数值。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- ①：以包含恶魔族怪兽的自己场上最多2只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果破坏怪兽时，以那个数量的对方场上的表侧表示怪兽为对象才能发动。这张卡的攻击力直到下次的自己回合的结束时上升作为对象的怪兽的原本攻击力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断怪兽是否可以成为效果对象
function s.cfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 判断选择的怪兽组是否包含恶魔族怪兽
function s.fselect(g)
	return g:IsExists(Card.IsRace,1,nil,RACE_FIEND)
end
-- ①效果的发动时点处理函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取满足条件的场上怪兽组
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,e)
	-- 检查是否满足①效果的发动条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and rg:CheckSubGroup(s.fselect,1,2) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=rg:SelectSubGroup(tp,s.fselect,false,1,2)
	-- 设置当前效果的目标怪兽
	Duel.SetTargetCard(sg)
	-- 设置效果操作信息，准备特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与连锁相关的当前目标怪兽
	local tg=Duel.GetTargetsRelateToChain()
	-- 将此卡特殊召唤到场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 破坏目标怪兽
		local dt=Duel.Destroy(tg,REASON_EFFECT)
		if dt>0 then
			-- 触发自定义事件，用于激活②效果
			Duel.RaiseEvent(c,EVENT_CUSTOM+id,re,r,tp,ep,dt)
		end
	end
end
-- ②效果的发动条件判断函数
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==rp and eg and eg:IsContains(e:GetHandler())
end
-- 判断怪兽是否为正面表示且攻击力大于0
function s.atkfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
-- ②效果的目标选择函数
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.atkfilter(chkc) end
	-- 检查是否满足②效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,0,LOCATION_MZONE,ev,nil) end
	-- 提示玩家选择②效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择②效果的目标怪兽
	Duel.SelectTarget(tp,s.atkfilter,tp,0,LOCATION_MZONE,ev,ev,nil)
end
-- ②效果的处理函数
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与连锁相关的当前目标怪兽
	local tg=Duel.GetTargetsRelateToChain()
	local atk=tg:GetSum(Card.GetBaseAttack)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将攻击力提升效果应用到此卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
	end
end
