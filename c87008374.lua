--ZW－不死鳥弩弓
-- 效果：
-- 这张卡可以从手卡当作装备卡使用给自己场上的「混沌No.39 希望皇 霍普雷」装备。用这个效果把这张卡装备的怪兽的攻击力上升1100。此外，装备怪兽战斗破坏对方怪兽时，给与对方基本分1000分伤害。「异热同心武器-不死鸟弩弓」在自己场上只能有1张表侧表示存在。
function c87008374.initial_effect(c)
	c:SetUniqueOnField(1,0,87008374)
	-- 这张卡可以从手卡当作装备卡使用给自己场上的「混沌No.39 希望皇 霍普雷」装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87008374,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c87008374.eqcon)
	e1:SetTarget(c87008374.eqtg)
	e1:SetOperation(c87008374.eqop)
	c:RegisterEffect(e1)
	-- 此外，装备怪兽战斗破坏对方怪兽时，给与对方基本分1000分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87008374,1))  --"伤害"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c87008374.damcon)
	e3:SetTarget(c87008374.damtg)
	e3:SetOperation(c87008374.damop)
	c:RegisterEffect(e3)
end
-- 装备效果发动条件：检查自己场上是否已存在同名卡（满足同名卡只能有1张表侧表示存在的限制）
function c87008374.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 过滤条件：筛选自己场上表侧表示的「混沌No.39 希望皇 霍普雷」
function c87008374.filter(c)
	return c:IsFaceup() and c:IsCode(56840427)
end
-- 装备效果的靶向选择：检查魔陷区空位并选择自己场上1只「混沌No.39 希望皇 霍普雷」作为效果对象
function c87008374.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c87008374.filter(chkc) end
	-- 判断自己场上的魔法与陷阱区域是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断自己场上是否存在可以作为装备对象的「混沌No.39 希望皇 霍普雷」
		and Duel.IsExistingTarget(c87008374.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送选择装备对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c87008374.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的处理：验证自身与对象的合法性，若合法则执行装备，否则送去墓地
function c87008374.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中选择的第一个效果对象（即要装备的怪兽）
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位、对象怪兽是否仍由自己控制且表侧表示、对象是否仍与效果相关联、以及自身是否满足场上唯一存在限制
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若不满足装备条件，则将这张卡因效果送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c87008374.zw_equip_monster(c,tp,tc)
end
-- 执行装备操作，并为装备卡注册装备限制以及攻击力上升的效果
function c87008374.zw_equip_monster(c,tp,tc)
	-- 将自身作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc) then return end
	-- 这张卡可以从手卡当作装备卡使用给自己场上的「混沌No.39 希望皇 霍普雷」装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c87008374.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 用这个效果把这张卡装备的怪兽的攻击力上升1100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1100)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 伤害效果发动条件：检查被战斗破坏的怪兽是否是由装备了此卡的怪兽所破坏
function c87008374.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec)
end
-- 伤害效果的靶向与操作信息：指定对方玩家为伤害对象，伤害数值为1000，并设置伤害操作信息
function c87008374.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数（伤害数值）设置为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为：给与对方玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害效果的处理：获取连锁信息中的对象玩家和伤害数值，并给与对方玩家相应的伤害
function c87008374.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家相应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 装备限制：此卡只能装备给作为其效果对象的怪兽
function c87008374.eqlimit(e,c)
	return c==e:GetLabelObject()
end
