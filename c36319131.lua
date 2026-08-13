--闘気炎斬龍
-- 效果：
-- 龙族怪兽＋战士族·炎属性怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合，以自己场上1只战士族融合怪兽为对象才能发动。从自己的场上·墓地把这张卡当作装备魔法卡使用给那只自己怪兽装备。
-- ②：只要这张卡给「炎之剑士」或者有那个卡名记述的怪兽装备中，装备怪兽的攻击力上升700，同1次的战斗阶段中可以作2次攻击。
local s,id,o=GetID()
-- 初始化卡片的融合召唤手续，并注册①的装备效果、②的攻击力上升与追加攻击效果。
function s.initial_effect(c)
	-- 在卡片数据中登记卡名「炎之剑士」（45231177），使后续可以检测“有那个卡名记述的怪兽”。
	aux.AddCodeList(c,45231177)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只龙族怪兽和1只战士族·炎属性怪兽（由s.ffilter过滤）作为融合素材进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),s.ffilter,true)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己·对方回合，以自己场上1只战士族融合怪兽为对象才能发动。从自己的场上·墓地把这张卡当作装备魔法卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡给「炎之剑士」或者有那个卡名记述的怪兽装备中，装备怪兽的攻击力上升700。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.eqcon)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- ②：只要这张卡给「炎之剑士」或者有那个卡名记述的怪兽装备中，同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(s.eqcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤融合素材：素材怪兽必须是战士族且炎属性，对应效果原文中的“战士族·炎属性怪兽”。
function s.ffilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsFusionAttribute(ATTRIBUTE_FIRE)
end
-- 过滤装备对象：对象必须是自己场上表侧表示的战士族融合怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_FUSION)
end
-- 设置①效果的发动条件与取对象判定：连锁中验证目标是否在自己场上且符合条件；发动时检查魔陷区有空位、场上无同名卡、存在合法对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查自己魔陷区是否还有空位，确保这张卡可以装备到魔陷区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(tp)
		-- 检查自己场上是否存在至少1只表侧表示的战士族融合怪兽，可以作为此效果的对象。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 向操作玩家显示“请选择要装备的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的战士族融合怪兽作为这张卡装备的对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,c)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 如果这张卡在墓地发动，设置操作信息：这张卡将因效果从墓地离开，用于配合王家长眠之谷等涉及墓地效果的正确判定。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 效果处理：若这张卡仍与效果关联，则取出对象；若装备条件全部满足，则将这张卡装备给对象怪兽，否则将其送入墓地；成功装备后为这张卡设置只能装备给该对象怪兽的限制。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得发动时选择的目标怪兽（作为装备对象）。
	local tc=Duel.GetFirstTarget()
	-- 判断装备是否合法：自己魔陷区是否还有空位、目标是否仍在自己场上表侧表示、目标是否仍与效果关联、这张卡是否仍能因同名卡限制而出现在场上；任一条件不满足则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 因装备条件不满足或处理失败，将这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备魔法卡装备给选择的目标怪兽；若装备失败则直接结束处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 当作装备魔法卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制函数：只有当卡c是效果发动时选择的目标怪兽（通过LabelObject记录）时才允许装备。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果的适用条件：这张卡装备中的怪兽是「炎之剑士」或者卡名记述了「炎之剑士」的怪兽。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local qc=e:GetHandler():GetEquipTarget()
	-- 判断装备怪兽的卡名是否为「炎之剑士」（45231177）或其效果文本中记载了「炎之剑士」的卡名。
	return (qc:IsCode(45231177) or aux.IsCodeListed(qc,45231177))
end
