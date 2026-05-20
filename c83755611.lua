--輝竜星－ショウフク
-- 效果：
-- 调整＋调整以外的幻龙族怪兽1只以上
-- ①：这张卡同调召唤成功时，以最多有作为这张卡的同调素材的幻龙族怪兽的原本属性种类数量的场上的卡为对象才能发动。那些卡回到持有者卡组。
-- ②：1回合1次，以自己场上1张卡和自己墓地1只4星以下的怪兽为对象才能发动。那张场上的卡破坏，那只墓地的怪兽特殊召唤。
function c83755611.initial_effect(c)
	-- 设置同调召唤的手续：调整+调整以外的幻龙族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_WYRM),1)
	c:EnableReviveLimit()
	-- 作为这张卡的同调素材的幻龙族怪兽的原本属性种类数量
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c83755611.matcheck)
	c:RegisterEffect(e1)
	-- ①：这张卡同调召唤成功时，以最多有作为这张卡的同调素材的幻龙族怪兽的原本属性种类数量的场上的卡为对象才能发动。那些卡回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83755611,0))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c83755611.tdcon)
	e2:SetTarget(c83755611.tdtg)
	e2:SetOperation(c83755611.tdop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1张卡和自己墓地1只4星以下的怪兽为对象才能发动。那张场上的卡破坏，那只墓地的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83755611,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c83755611.destg)
	e3:SetOperation(c83755611.desop)
	c:RegisterEffect(e3)
end
-- 检查同调素材，计算作为同调素材的幻龙族怪兽的原本属性种类数量，并保存在Label中
function c83755611.matcheck(e,c)
	local ct=c:GetMaterial():Filter(Card.IsRace,nil,RACE_WYRM):GetClassCount(Card.GetOriginalAttribute)
	e:SetLabel(ct)
end
-- 触发条件：这张卡同调召唤成功
function c83755611.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果1（弹回卡组）的发动准备，确认是否有合法的场上卡片作为对象，并进行取对象操作
function c83755611.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	local ct=e:GetLabelObject():GetLabel()
	-- 检查场上是否存在至少1张可以回到卡组的卡，且同调素材中的幻龙族怪兽原本属性种类数量大于0
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择最多等同于属性种类数量的场上的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置连锁信息，表明该效果的操作分类为“送回卡组”，操作对象为选中的卡片组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果1（弹回卡组）的效果处理，将仍存在于场上且仍满足对象条件的卡送回持有者卡组并洗牌
function c83755611.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标卡片组送回持有者卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤自己场上要破坏的卡，若怪兽区域已满，则必须选择主要怪兽区域的怪兽以腾出格子
function c83755611.desfilter(c,ft)
	return ft>0 or (c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5)
end
-- 过滤自己墓地中等级4以下且可以特殊召唤的怪兽
function c83755611.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2（破坏并特召）的发动准备，检查场上是否有可破坏的卡以及墓地是否有可特召的怪兽，并选择对象
function c83755611.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取玩家场上主要怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1
		-- 检查自己场上是否存在至少1张满足破坏过滤条件的卡
		and Duel.IsExistingTarget(c83755611.desfilter,tp,LOCATION_ONFIELD,0,1,nil,ft)
		-- 检查自己墓地是否存在至少1只满足特殊召唤过滤条件的怪兽
		and Duel.IsExistingTarget(c83755611.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择自己场上1张要破坏的卡作为对象
	local g1=Duel.SelectTarget(tp,c83755611.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,ft)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只4星以下的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c83755611.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明该效果的操作分类为“破坏”，操作对象为选中的场上卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置连锁信息，表明该效果的操作分类为“特殊召唤”，操作对象为选中的墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
-- 效果2（破坏并特召）的效果处理，破坏选中的场上卡片，若破坏成功，则将选中的墓地怪兽特殊召唤
function c83755611.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中关于“破坏”操作的对象卡片组
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	-- 获取连锁信息中关于“特殊召唤”操作的对象卡片组
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	-- 检查破坏对象是否仍与效果相关，并执行破坏。若破坏成功且特召对象仍与效果相关，则继续处理
	if tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)~=0 and tc2:IsRelateToEffect(e) then
		-- 将目标墓地怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
