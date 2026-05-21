--超重武者装留チュウサイ
-- 效果：
-- 「超重武者装留 仲裁」的③的效果1回合只能使用1次。
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
-- ②：这张卡的效果让这张卡装备中的场合，对方不能向装备怪兽以外的自己怪兽攻击。
-- ③：把用这张卡的效果把这张卡装备的自己怪兽解放才能发动。从卡组把1只「超重武者」怪兽特殊召唤。
function c95500396.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c95500396.eqtg)
	e1:SetOperation(c95500396.eqop)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的「超重武者」怪兽
function c95500396.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 装备效果的对象筛选与目标选择
function c95500396.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c95500396.eqfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在除自身以外的、可作为装备对象的表侧表示「超重武者」怪兽
		and Duel.IsExistingTarget(c95500396.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「超重武者」怪兽作为装备对象
	Duel.SelectTarget(tp,c95500396.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 装备效果的处理，将自身装备给目标怪兽，并注册装备限制、攻击限制以及解放特召效果
function c95500396.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位、目标怪兽是否仍在场、是否表侧表示以及是否仍是此效果的有效对象
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若无法装备，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c95500396.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果让这张卡装备中的场合，对方不能向装备怪兽以外的自己怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c95500396.atlimit)
	e2:SetLabelObject(tc)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 「超重武者装留 仲裁」的③的效果1回合只能使用1次。③：把用这张卡的效果把这张卡装备的自己怪兽解放才能发动。从卡组把1只「超重武者」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,95500396)
	e3:SetCost(c95500396.spcost)
	e3:SetTarget(c95500396.sptg)
	e3:SetOperation(c95500396.spop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
-- 限制这张卡只能装备给通过效果选择的目标怪兽
function c95500396.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 限制对方不能选择装备怪兽以外的自己怪兽作为攻击对象
function c95500396.atlimit(e,c)
	return c~=e:GetLabelObject()
end
-- 特殊召唤效果的发动代价判定与执行
function c95500396.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 检查装备怪兽是否可解放，且解放后是否有可用的怪兽区域用于特殊召唤
	if chk==0 then return c:GetControler()==tc:GetControler() and tc:IsReleasable() and Duel.GetMZoneCount(tp,tc)>0 end
	-- 解放装备怪兽作为发动的代价
	Duel.Release(tc,REASON_COST)
end
-- 过滤卡组中可以特殊召唤的「超重武者」怪兽
function c95500396.spfilter(c,e,tp)
	return c:IsSetCard(0x9a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备，检查卡组中是否存在可特殊召唤的怪兽并设置操作信息
function c95500396.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的「超重武者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95500396.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息为“从卡组特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行，从卡组选择1只「超重武者」怪兽特殊召唤
function c95500396.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的「超重武者」怪兽
	local g=Duel.SelectMatchingCard(tp,c95500396.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
