--サウザンド・アイズ・サクリファイス
-- 效果：
-- 「纳祭之魔」＋「千眼邪教神」
-- ①：只要这张卡在怪兽区域存在，这张卡以外的场上的怪兽不能攻击，也不能作表示形式的变更。
-- ②：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备卡使用给这张卡装备（只有1只可以装备）。
-- ③：这张卡的攻击力·守备力变成这张卡的效果装备的怪兽的各自数值，这张卡被战斗破坏的场合，作为代替把装备的那只怪兽破坏。
function c63519819.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，素材为「纳祭之魔」和「千眼邪教神」
	aux.AddFusionProcCode2(c,64631466,27125110,true,true)
	-- ②：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备卡使用给这张卡装备（只有1只可以装备）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63519819,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c63519819.eqcon)
	e1:SetTarget(c63519819.eqtg)
	e1:SetOperation(c63519819.eqop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，这张卡以外的场上的怪兽不能攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c63519819.antarget)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	c:RegisterEffect(e3)
	-- ③：这张卡的攻击力·守备力变成这张卡的效果装备的怪兽的各自数值
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_SET_ATTACK)
	e4:SetCondition(c63519819.adcon)
	e4:SetValue(c63519819.atkval)
	c:RegisterEffect(e4)
	-- ③：这张卡的攻击力·守备力变成这张卡的效果装备的怪兽的各自数值
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_SET_DEFENSE)
	e5:SetCondition(c63519819.adcon)
	e5:SetValue(c63519819.defval)
	c:RegisterEffect(e5)
end
-- 装备效果的发动条件：自身当前没有通过自身效果装备的怪兽
function c63519819.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c63519819.can_equip_monster(c)
end
-- 过滤通过本卡效果装备的怪兽（带有本卡卡号Flag的卡）
function c63519819.eqfilter(c)
	return c:GetFlagEffect(63519819)~=0
end
-- 判定当前是否可以装备怪兽（检查通过本卡效果装备的怪兽数量是否为0）
function c63519819.can_equip_monster(c)
	local g=c:GetEquipGroup():Filter(c63519819.eqfilter,nil)
	return g:GetCount()==0
end
-- 装备效果的Target（发动准备）函数：检查魔法与陷阱区域是否有空位，并选择对方场上1只怪兽作为对象
function c63519819.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	-- 检查自身魔法与陷阱区域是否有空余格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在可以转移控制权的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择要装备的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只可以转移控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制：该装备卡只能装备给当前效果的拥有者（即本卡）
function c63519819.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行装备怪兽的具体处理，并为装备卡添加装备限制和代替破坏效果
function c63519819.equip_monster(c,tp,tc)
	if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and not c63519819.can_equip_monster(c) then
		-- 若因规则无法装备（如已有装备怪兽），则将目标怪兽因规则送去墓地
		Duel.SendtoGrave(tc,REASON_RULE)
		return
	end
	-- 将目标怪兽作为装备卡装备给本卡，若装备失败则结束处理
	if not Duel.Equip(tp,tc,c,false) then return end
	tc:RegisterFlagEffect(63519819,RESET_EVENT+RESETS_STANDARD,0,0)
	-- ②：那只对方怪兽当作装备卡使用给这张卡装备（只有1只可以装备）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c63519819.eqlimit)
	tc:RegisterEffect(e1)
	-- ③：这张卡被战斗破坏的场合，作为代替把装备的那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(c63519819.repval)
	tc:RegisterEffect(e2)
end
-- 装备效果的Operation（效果处理）函数：获取对象怪兽，若其仍满足条件则将其装备给本卡
function c63519819.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsControler(1-tp) then
		c63519819.equip_monster(c,tp,tc)
	end
end
-- 代替破坏的判定：仅在因战斗破坏时适用代替破坏
function c63519819.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 限制攻击和表示形式变更的对象过滤：适用于本卡以外的场上所有怪兽
function c63519819.antarget(e,c)
	return c~=e:GetHandler()
end
-- 攻击力·守备力数值变更的适用条件：本卡当前装备有通过自身效果装备的怪兽
function c63519819.adcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c63519819.eqfilter,nil)
	return g:GetCount()>0
end
-- 攻击力数值计算：获取装备怪兽的原本攻击力，若其为里侧表示、非怪兽卡或数值小于0则视为0
function c63519819.atkval(e,c)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c63519819.eqfilter,nil)
	local atk=g:GetFirst():GetTextAttack()
	if g:GetFirst():IsFacedown() or bit.band(g:GetFirst():GetOriginalType(),TYPE_MONSTER)==0 or atk<0 then
		return 0
	else
		return atk
	end
end
-- 守备力数值计算：获取装备怪兽的原本守备力，若其为里侧表示、非怪兽卡或数值小于0则视为0
function c63519819.defval(e,c)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(c63519819.eqfilter,nil)
	local def=g:GetFirst():GetTextDefense()
	if g:GetFirst():IsFacedown() or bit.band(g:GetFirst():GetOriginalType(),TYPE_MONSTER)==0 or def<0 then
		return 0
	else
		return def
	end
end
