--栄光の聖騎士団
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「圣骑士」怪兽为对象才能发动。从卡组选1张那只自己怪兽可以装备的装备魔法卡给那只怪兽装备。
function c75719089.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「圣骑士」怪兽为对象才能发动。从卡组选1张那只自己怪兽可以装备的装备魔法卡给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,75719089+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c75719089.target)
	e1:SetOperation(c75719089.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「圣骑士」怪兽，且卡组中存在该怪兽可以装备的装备魔法卡
function c75719089.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x107a)
		-- 检查卡组中是否存在至少1张该怪兽可以装备的装备魔法卡
		and Duel.IsExistingMatchingCard(c75719089.eqfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
end
-- 过滤卡组中可以装备给目标怪兽、且在场上唯一存在、未被禁止的装备魔法卡
function c75719089.eqfilter(c,tc,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 效果发动时的对象选择与可行性检查
function c75719089.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c75719089.filter(chkc,tp) end
	local ft=0
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=1 end
	-- 检查魔法与陷阱区域是否有空位（若从手牌发动，则需要扣除自身占用的1格）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>ft
		-- 检查自己场上是否存在可以作为对象的「圣骑士」怪兽
		and Duel.IsExistingTarget(c75719089.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「圣骑士」怪兽作为效果的对象
	Duel.SelectTarget(tp,c75719089.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果处理的核心逻辑，将卡组中的装备魔法卡装备给目标怪兽
function c75719089.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否有可用空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 提示玩家选择要装备的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组中选择1张该怪兽可以装备的装备魔法卡
		local g=Duel.SelectMatchingCard(tp,c75719089.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tc,tp)
		if g:GetCount()>0 then
			-- 将选中的装备魔法卡装备给目标怪兽
			Duel.Equip(tp,g:GetFirst(),tc)
		end
	end
end
