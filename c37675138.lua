--ボーンクラッシャー
-- 效果：
-- 这张卡被不死族怪兽的效果从自己墓地特殊召唤时，可以把对方场上存在的1张魔法·陷阱卡破坏。这张卡在特殊召唤的回合的结束阶段时破坏。
function c37675138.initial_effect(c)
	-- 诱发选发效果，当此卡被不死族怪兽从自己墓地特殊召唤时发动，破坏对方场上1张魔法·陷阱卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37675138,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c37675138.descon)
	e1:SetTarget(c37675138.destg)
	e1:SetOperation(c37675138.desop)
	c:RegisterEffect(e1)
	-- 在特殊召唤成功时发动的效果，用于注册结束阶段破坏效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c37675138.regop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否由自己墓地被特殊召唤，且召唤者为不死族怪兽
function c37675138.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local typ,race=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return c:IsPreviousLocation(LOCATION_GRAVE) and e:GetHandler():IsPreviousControler(tp)
		and typ&TYPE_MONSTER~=0 and race&RACE_ZOMBIE~=0
end
-- 过滤魔法·陷阱卡的函数
function c37675138.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置选择目标，选择对方场上的魔法·陷阱卡作为破坏对象
function c37675138.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c37675138.desfilter(chkc) end
	-- 检查是否有对方场上的魔法·陷阱卡可被选择
	if chk==0 then return Duel.IsExistingTarget(c37675138.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c37675138.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作，将选择的魔法·陷阱卡破坏
function c37675138.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 注册结束阶段破坏效果，使此卡在特殊召唤回合结束时破坏
function c37675138.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 在结束阶段发动的效果，使此卡破坏自身
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(37675138,1))  --"自坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c37675138.sdtg)
	e1:SetOperation(c37675138.sdop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 设置结束阶段破坏效果的目标为自身
function c37675138.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏自身效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 执行破坏自身效果
function c37675138.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
