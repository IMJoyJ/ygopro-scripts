--ワンショット・キャノン
-- 效果：
-- 「一击喷射士」＋调整以外的怪兽1只
-- 1回合1次，把场上表侧表示存在的1只怪兽破坏，给与那个控制者破坏怪兽的攻击力一半数值的伤害。
function c13574687.initial_effect(c)
	-- 为该同调怪兽登记素材卡名列表，将「一击喷射士」（密码6142213）加入素材名单，用于辅助判定同调素材限制。
	aux.AddMaterialCodeList(c,6142213)
	-- 为这张卡设置同调召唤手续：同调素材为1只卡名是「一击喷射士」的调整＋1只调整以外的怪兽（合计2只），且「一击喷射士」必须作为调整素材。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,6142213),aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- 1回合1次，把场上表侧表示存在的1只怪兽破坏，给与那个控制者破坏怪兽的攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13574687,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c13574687.target)
	e1:SetOperation(c13574687.operation)
	c:RegisterEffect(e1)
end
-- 定义效果对象的过滤条件：选择场上表侧表示存在的怪兽作为可选对象。
function c13574687.filter(c)
	return c:IsFaceup()
end
-- 发动时选择对象与登记操作信息：先处理取对象判定，再确认场上是否存在可选择的表侧表示怪兽；存在则让玩家选择1只表侧表示怪兽为对象，并登记破坏该对象以及给对方造成该怪兽攻击力一半伤害的操作信息。
function c13574687.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c13574687.filter(chkc) end
	-- 发动条件判定：确认双方怪兽区域是否存在至少1只表侧表示且能被选择为对象的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c13574687.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发送“请选择要破坏的卡”的选择提示信息，用于选择对象的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方怪兽区域选择1张表侧表示怪兽作为效果对象，该卡会被自动登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c13574687.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本连锁将要进行的破坏操作信息：指定破坏分类，目标为已选择的怪兽g，数量为1，控制者与位置参数暂不固定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记本连锁将要造成的伤害操作信息：伤害分类，目标卡不确定（按实际处理时计算），伤害接受者为所选怪兽的控制者，伤害数值为所选怪兽当前攻击力的一半。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,g:GetFirst():GetControler(),math.floor(g:GetFirst():GetAttack()/2))
end
-- 效果处理：取回对象怪兽，若其仍表侧表示且与该发动效果关联，则计算其攻击力一半作为伤害并取得其控制者；先以其效果破坏该怪兽，破坏成功后再给予该控制者等量伤害。
function c13574687.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理时记录的对象卡，即发动时选择的那只表侧表示怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local dam=math.floor(tc:GetAttack()/2)
		local p=tc:GetControler()
		-- 以效果原因破坏对象怪兽；若实际破坏成功（返回值不为0），则继续执行后续伤害。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给予对象怪兽的控制者p造成dam点效果伤害，dam为破坏时该怪兽攻击力的一半。
			Duel.Damage(p,dam,REASON_EFFECT)
		end
	end
end
