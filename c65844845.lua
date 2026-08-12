--甲虫装機 ギガグリオル
-- 效果：
-- 可以把自己墓地1只昆虫族怪兽从游戏中除外，墓地的这张卡当作装备卡使用给自己场上1只名字带有「甲虫装机」的怪兽装备。「甲虫装机 吉咖蝼蛄」的这个效果1回合只能使用1次。此外，这张卡当作装备卡使用而装备中的场合，装备怪兽的原本攻击力变成2000，装备怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c65844845.initial_effect(c)
	-- 可以把自己墓地1只昆虫族怪兽从游戏中除外，墓地的这张卡当作装备卡使用给自己场上1只名字带有「甲虫装机」的怪兽装备。「甲虫装机 吉咖蝼蛄」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65844845,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,65844845)
	e1:SetCost(c65844845.eqcost)
	e1:SetTarget(c65844845.eqtg)
	e1:SetOperation(c65844845.eqop)
	c:RegisterEffect(e1)
	-- 此外，这张卡当作装备卡使用而装备中的场合，装备怪兽的原本攻击力变成2000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetValue(2000)
	c:RegisterEffect(e2)
	-- 装备怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中可以作为代价除外的昆虫族怪兽
function c65844845.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的代价：将自己墓地1只昆虫族怪兽除外
function c65844845.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己墓地是否存在除自身以外、可作为代价除外的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65844845.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地中1只除自身以外的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c65844845.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选择的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤场上表侧表示的名字带有「甲虫装机」的怪兽
function c65844845.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 效果发动的目标：检查魔陷区是否有空位，并选择场上1只表侧表示的「甲虫装机」怪兽作为效果对象
function c65844845.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c65844845.filter(chkc) end
	-- 在发动效果时，检查自己场上的魔法与陷阱区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并检查自己场上是否存在可以作为效果对象的、表侧表示的「甲虫装机」怪兽
		and Duel.IsExistingTarget(c65844845.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「甲虫装机」怪兽作为效果对象
	Duel.SelectTarget(tp,c65844845.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理的操作信息为“将墓地的这张卡移出墓地”
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：将墓地的这张卡作为装备卡装备给目标怪兽，并添加装备限制
function c65844845.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查自己场上魔法与陷阱区域是否有空位，且目标怪兽是否仍表侧表示存在并受此效果影响，若不满足则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 当作装备卡使用给自己场上1只名字带有「甲虫装机」的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c65844845.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 限制这张卡只能装备给作为效果对象的那只怪兽
function c65844845.eqlimit(e,c)
	return c==e:GetLabelObject()
end
