--No.57 奮迅竜トレスラグーン
-- 效果：
-- 4星怪兽×3
-- ①：这张卡特殊召唤成功时，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力上升那只怪兽的攻击力数值。
-- ②：对方场上的卡数量比自己场上的卡多的场合，把这张卡1个超量素材取除，指定没有使用的怪兽区域或者没有使用的魔法与陷阱区域1处才能发动。这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，指定的区域不能使用。
function c53244294.initial_effect(c)
	-- 添加XYZ召唤手续，使用3只4星怪兽进行XYZ召唤
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功时，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力上升那只怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53244294,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c53244294.atktg)
	e1:SetOperation(c53244294.atkop)
	c:RegisterEffect(e1)
	-- ②：对方场上的卡数量比自己场上的卡多的场合，把这张卡1个超量素材取除，指定没有使用的怪兽区域或者没有使用的魔法与陷阱区域1处才能发动。这张卡得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53244294,1))  --"区域封锁"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c53244294.zcon)
	e2:SetCost(c53244294.zcost)
	e2:SetTarget(c53244294.ztg)
	e2:SetOperation(c53244294.zop)
	c:RegisterEffect(e2)
end
-- 设置该卡为No.57奋迅龙三头龙
aux.xyz_number[53244294]=57
-- 设置效果目标为对方场上的1只表侧表示怪兽
function c53244294.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足选择目标的条件，即对方场上存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 将自身攻击力提升为所选怪兽的攻击力数值
function c53244294.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使自身攻击力增加目标怪兽的攻击力数值并设置重置条件
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断是否满足发动条件，即对方场上的卡数量比自己场上的卡多
function c53244294.zcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较对方场上卡的数量与己方场上卡的数量
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
-- 支付效果代价，从自身场上取除1个超量素材
function c53244294.zcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断是否满足选择区域的条件，即存在至少一个可用的怪兽区或魔法陷阱区
function c53244294.ztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算己方怪兽区的空位数量
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
		-- 计算对方怪兽区的空位数量
		+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
		-- 计算己方魔法陷阱区的空位数量
		+Duel.GetLocationCount(tp,LOCATION_SZONE,PLAYER_NONE,0)
		-- 计算对方魔法陷阱区的空位数量
		+Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>0 end
	-- 选择一个区域使其不能使用
	local dis=Duel.SelectDisableField(tp,1,LOCATION_ONFIELD,LOCATION_ONFIELD,0xe000e0)
	e:SetLabel(dis)
	-- 向玩家提示所选区域
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 将指定区域设为不可使用状态
function c53244294.zop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	-- 使指定区域在场上无法使用
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(zone)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e:GetHandler():RegisterEffect(e1)
end
