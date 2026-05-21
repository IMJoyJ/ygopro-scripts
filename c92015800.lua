--No.76 諧調光師グラディエール
-- 效果：
-- 7星怪兽×2
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的属性也当作这张卡作为超量素材中的怪兽的各自属性使用。
-- ②：这张卡不会被和持有和这张卡相同属性的怪兽的战斗破坏，不会被持有和这张卡相同属性的对方怪兽发动的效果破坏。
-- ③：以对方墓地1只怪兽为对象才能发动。这张卡1个超量素材取除，把作为对象的怪兽在这张卡下面重叠作为超量素材。这个效果在对方回合也能发动。
function c92015800.initial_effect(c)
	-- 添加XYZ召唤手续：等级7怪兽×2
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：这张卡的属性也当作这张卡作为超量素材中的怪兽的各自属性使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(c92015800.attval)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被和持有和这张卡相同属性的怪兽的战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(c92015800.indval1)
	c:RegisterEffect(e2)
	-- 不会被持有和这张卡相同属性的对方怪兽发动的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(c92015800.indval2)
	c:RegisterEffect(e3)
	-- ③：以对方墓地1只怪兽为对象才能发动。这张卡1个超量素材取除，把作为对象的怪兽在这张卡下面重叠作为超量素材。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(92015800,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,92015800)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetTarget(c92015800.xyztg)
	e4:SetOperation(c92015800.xyzop)
	c:RegisterEffect(e4)
end
-- 设置该怪兽的“No.”编号为76
aux.xyz_number[92015800]=76
-- 过滤超量素材中的怪兽卡
function c92015800.effilter(c)
	return c:IsType(TYPE_MONSTER)
end
-- 计算并返回这张卡作为超量素材的所有怪兽的属性并集
function c92015800.attval(e,c)
	local c=e:GetHandler()
	local og=c:GetOverlayGroup()
	local wg=og:Filter(c92015800.effilter,nil)
	local wbc=wg:GetFirst()
	local att=0
	while wbc do
		att=att|wbc:GetAttribute()
		wbc=wg:GetNext()
	end
	return att
end
-- 判定进行战斗的对方怪兽的属性是否与自身属性相同
function c92015800.indval1(e,c)
	return c:GetBattleTarget():GetAttribute()&c:GetAttribute()~=0
end
-- 判定发动效果的对方怪兽在场上（或原本）的属性是否与自身属性相同
function c92015800.indval2(e,re,rp)
	if not (rp==1-e:GetHandlerPlayer() and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)) then return false end
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsControler(rp) and (rc:IsFaceup() or not rc:IsLocation(LOCATION_MZONE)) then
		return e:GetHandler():IsAttribute(rc:GetAttribute())
	else
		return e:GetHandler():IsAttribute(rc:GetOriginalAttribute())
	end
end
-- 过滤对方墓地中可以作为超量素材的怪兽卡
function c92015800.xyzfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果③的靶向与发动条件判定（包含取对象处理）
function c92015800.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c92015800.xyzfilter(chkc) end
	-- 判定对方墓地是否存在可作为超量素材的怪兽，且自身有可取除的超量素材
	if chk==0 then return Duel.IsExistingTarget(c92015800.xyzfilter,tp,0,LOCATION_GRAVE,1,nil)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择对方墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c92015800.xyzfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息为“使卡片离开墓地”
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果③的执行函数：取除自身1个素材，并将目标怪兽重叠作为自身的超量素材
function c92015800.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将目标怪兽重叠在自身下方作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
