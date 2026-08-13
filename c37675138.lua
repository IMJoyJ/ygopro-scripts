--ボーンクラッシャー
-- 效果：
-- 这张卡被不死族怪兽的效果从自己墓地特殊召唤时，可以把对方场上存在的1张魔法·陷阱卡破坏。这张卡在特殊召唤的回合的结束阶段时破坏。
function c37675138.initial_effect(c)
	-- 这张卡被不死族怪兽的效果从自己墓地特殊召唤时，可以把对方场上存在的1张魔法·陷阱卡破坏。
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
	-- 这张卡在特殊召唤的回合的结束阶段时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c37675138.regop)
	c:RegisterEffect(e2)
end
-- 特殊召唤成功时的条件判定：确认此卡被从自己墓地特殊召唤、此前控制者为自己，并通过特殊召唤信息（类型为怪兽、种族为不死族）确认该特殊召唤是不死族怪兽的效果进行的特殊召唤。
function c37675138.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local typ,race=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return c:IsPreviousLocation(LOCATION_GRAVE) and e:GetHandler():IsPreviousControler(tp)
		and typ&TYPE_MONSTER~=0 and race&RACE_ZOMBIE~=0
end
-- 对象筛选函数：判断一张卡是否为魔法·陷阱卡（场上的魔法·陷阱卡）。
function c37675138.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 目标选择函数：效果发动时检查对方场上是否有可破坏的魔法·陷阱卡，若有则让玩家选择对方场上1张魔法·陷阱卡作为对象，并设置破坏操作信息。
function c37675138.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c37675138.desfilter(chkc) end
	-- 效果发动合法检查：在发动时确认对方场上存在至少1张可选择为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c37675138.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从对方场上选择1张满足过滤条件的魔法·陷阱卡，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c37675138.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将本次效果要破坏的对象和数量写入当前连锁的操作信息，用于后续对‘破坏’效果的响应判定（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取出对象，若对象仍与效果关联，则以效果原因将其破坏。
function c37675138.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获得本次连锁中第一个被选择作为对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将取出的对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 特殊召唤成功时触发的辅助操作：为这张卡注册一个结束阶段时必定发动的自坏诱发效果（在怪兽区域生效）；该效果会在通常的重置条件（离开场上、回到手牌/卡组等）以及结束阶段后重置。
function c37675138.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡在特殊召唤的回合的结束阶段时破坏。
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
-- 自坏效果的发动条件：在结束阶段必定成立；同时将“破坏这张卡”登记为操作信息。
function c37675138.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息：破坏对象为效果持有者自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 自坏效果处理：若该卡仍与效果关联且为表侧表示，则将其破坏。
function c37675138.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 以效果原因此卡自身破坏。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
