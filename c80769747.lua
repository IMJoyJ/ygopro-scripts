--C・スネーク
-- 效果：
-- 自己的主要阶段时可以当作装备卡使用给对方场上存在的1只表侧表示怪兽装备。这张卡装备的怪兽的攻击力·守备力下降800。装备怪兽被战斗破坏送去墓地时，从装备怪兽的控制者的卡组上面把和那只怪兽的等级相同数量的卡送去墓地。
function c80769747.initial_effect(c)
	-- 自己的主要阶段时可以当作装备卡使用给对方场上存在的1只表侧表示怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80769747,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c80769747.eqtg)
	e1:SetOperation(c80769747.eqop)
	c:RegisterEffect(e1)
	-- 装备怪兽被战斗破坏送去墓地时，从装备怪兽的控制者的卡组上面把和那只怪兽的等级相同数量的卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80769747,1))  --"卡组送墓"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c80769747.ddescon)
	e2:SetTarget(c80769747.ddestg)
	e2:SetOperation(c80769747.ddesop)
	c:RegisterEffect(e2)
end
-- 装备效果的对象筛选与合法性检查
function c80769747.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查自身魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示信息为表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为将自身作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义装备限制：只能装备给此效果指定的怪兽
function c80769747.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果的执行：将自身装备给目标怪兽，并注册降低攻击力与守备力的效果
function c80769747.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取已选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 在自身仍在场且表侧表示的情况下，将自身装备给目标怪兽
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.Equip(tp,c,tc) then
		-- 当作装备卡使用给对方场上存在的1只表侧表示怪兽装备
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c80769747.eqlimit)
		c:RegisterEffect(e1)
		-- 这张卡装备的怪兽的攻击力...下降800
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(-800)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 守备力下降800
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		e3:SetValue(-800)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
end
-- 判断装备怪兽是否因战斗破坏送去墓地，并保存该怪兽的信息
function c80769747.ddescon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	if c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_BATTLE) and ec:IsLocation(LOCATION_GRAVE) then
		e:SetLabelObject(ec)
		return true
	else return false end
end
-- 设置卡组送墓效果的对象玩家、送墓数量及操作信息
function c80769747.ddestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetLabelObject()
	local desp=ec:GetPreviousControler()
	local desc=ec:GetLevel()
	-- 将效果的对象玩家设置为装备怪兽的前控制者
	Duel.SetTargetPlayer(desp)
	-- 将效果的参数设置为装备怪兽的等级
	Duel.SetTargetParam(desc)
	-- 设置操作信息为将指定数量的卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,desp,desc)
end
-- 执行卡组送墓效果
function c80769747.ddesop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前设定的对象玩家和送墓卡片数量
	local dp,dc=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将目标玩家卡组最上方对应数量的卡送去墓地
	Duel.DiscardDeck(dp,dc,REASON_EFFECT)
end
