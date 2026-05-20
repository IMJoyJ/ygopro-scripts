--聖騎士伝説の終幕
-- 效果：
-- 「圣骑士传说的终幕」在1回合只能发动1张。
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，以自己墓地1只「圣骑士」怪兽和1张那只怪兽可以装备的「圣剑」装备魔法卡为对象才能发动。那只怪兽特殊召唤，那张装备魔法卡给作为正确对象的那只怪兽装备。
function c66970385.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，以自己墓地1只「圣骑士」怪兽和1张那只怪兽可以装备的「圣剑」装备魔法卡为对象才能发动。那只怪兽特殊召唤，那张装备魔法卡给作为正确对象的那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,66970385+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c66970385.condition)
	e1:SetTarget(c66970385.target)
	e1:SetOperation(c66970385.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件判定函数
function c66970385.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上没有怪兽且对方场上有怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤自己墓地中可以特殊召唤，且有可装备「圣剑」的「圣骑士」怪兽
function c66970385.filter(c,e,tp)
	return c:IsSetCard(0x107a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地中是否存在该怪兽可以装备的「圣剑」装备魔法卡
		and Duel.IsExistingTarget(c66970385.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp,c)
end
-- 过滤自己墓地中可以装备给指定怪兽且不在场上重复的「圣剑」装备魔法卡
function c66970385.eqfilter(c,tp,ec)
	return c:IsSetCard(0x207a) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(ec) and not c:IsForbidden()
end
-- 定义效果发动的目标选择与检测函数
function c66970385.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动时，检查自己场上是否至少有1个空余的怪兽区域和1个空余的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在符合条件的「圣骑士」怪兽
		and Duel.IsExistingTarget(c66970385.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「圣骑士」怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c66970385.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1张该怪兽可以装备的「圣剑」装备魔法卡作为效果对象
	local g2=Duel.SelectTarget(tp,c66970385.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp,g1:GetFirst())
	-- 向系统注册特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
	-- 向系统注册卡片离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,0)
end
-- 定义效果处理（激活）函数
function c66970385.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local ec=tg:GetFirst()
	if ec==tc then ec=tg:GetNext() end
	if tc:IsRelateToEffect(e) and ec:IsRelateToEffect(e) and ec:CheckUniqueOnField(tp) and ec:CheckEquipTarget(tc)
		-- 将作为对象的「圣骑士」怪兽表侧表示特殊召唤，并判断是否特殊召唤成功
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 将作为对象的「圣剑」装备魔法卡装备给该「圣骑士」怪兽
		Duel.Equip(tp,ec,tc)
	end
end
