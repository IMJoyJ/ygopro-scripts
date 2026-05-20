--プリン隊
-- 效果：
-- 这张卡不能作为融合·同调·超量召唤的素材。
-- ①：只要这张卡在怪兽区域存在，这张卡不能解放。
-- ②：自己结束阶段以自己的灵摆区域1张卡为对象才能发动。那张卡破坏，这张卡的控制权移给对方。
-- ③：自己准备阶段发动。自己受到300伤害。
function c85101097.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡不能解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	-- 这张卡不能作为融合·同调·超量召唤的素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(c85101097.fuslimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	-- ②：自己结束阶段以自己的灵摆区域1张卡为对象才能发动。那张卡破坏，这张卡的控制权移给对方。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(85101097,0))  --"控制权转移"
	e6:SetCategory(CATEGORY_DESTROY+CATEGORY_CONTROL)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c85101097.ctlcon)
	e6:SetTarget(c85101097.ctltg)
	e6:SetOperation(c85101097.ctlop)
	c:RegisterEffect(e6)
	-- ③：自己准备阶段发动。自己受到300伤害。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(85101097,1))  --"效果伤害"
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCondition(c85101097.damcon)
	e7:SetTarget(c85101097.damtg)
	e7:SetOperation(c85101097.damop)
	c:RegisterEffect(e7)
end
-- 限制融合召唤素材的辅助函数
function c85101097.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 控制权转移效果的发动条件：当前回合是自己的回合
function c85101097.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 控制权转移效果的发动目标判定与选择
function c85101097.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) end
	if chk==0 then return e:GetHandler():IsControlerCanBeChanged()
		-- 判定自己灵摆区域是否存在可以作为对象的目标卡片
		and Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己灵摆区域的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
	-- 设置连锁信息：包含破坏选定卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息：包含转移自身控制权的操作
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 控制权转移效果的处理逻辑
function c85101097.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的灵摆区域卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍适用此效果，则将其因效果破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡的控制权移给对方
		Duel.GetControl(c,1-tp)
	end
end
-- 伤害效果的发动条件：当前回合是自己的回合
function c85101097.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 伤害效果的发动目标判定与连锁信息设置
function c85101097.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息：给与自己300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,300)
end
-- 伤害效果的处理逻辑
function c85101097.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果给与自己300点伤害
	Duel.Damage(tp,300,REASON_EFFECT)
end
