--マスク・チェンジ・セカンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡，以自己场上1只表侧表示怪兽为对象才能发动。把那只怪兽的属性·等级确认，送去墓地。这个效果让那只怪兽从场上离开的场合，再把比那只怪兽等级高并持有相同属性的1只「假面英雄」怪兽当作「假面变化」的效果来从额外卡组特殊召唤。
function c93600443.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：丢弃1张手卡，以自己场上1只表侧表示怪兽为对象才能发动。把那只怪兽的属性·等级确认，送去墓地。这个效果让那只怪兽从场上离开的场合，再把比那只怪兽等级高并持有相同属性的1只「假面英雄」怪兽当作「假面变化」的效果来从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,93600443+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c93600443.cost)
	e1:SetTarget(c93600443.target)
	e1:SetOperation(c93600443.activate)
	c:RegisterEffect(e1)
end
-- 效果发动代价（Cost）处理：丢弃1张手卡
function c93600443.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡作为发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选自己场上可以作为此卡效果对象的表侧表示怪兽
function c93600443.filter(c,e,tp)
	local lv=c:GetLevel()
	local att=c:GetAttribute()
	return lv>0 and c:IsFaceup()
		-- 检查额外卡组是否存在满足特殊召唤条件的「假面英雄」怪兽
		and Duel.IsExistingMatchingCard(c93600443.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv,att,c)
end
-- 过滤函数：筛选额外卡组中符合特殊召唤条件的「假面英雄」怪兽
function c93600443.spfilter(c,e,tp,lv,att,mc)
	return c:IsSetCard(0xa008) and c:GetLevel()>lv and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_MASK_CHANGE,tp,false,true)
		-- 计算在作为对象的怪兽离场后，额外卡组怪兽特殊召唤所需的可用怪兽区域数量
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 过滤函数：用于在取对象时，检测该卡是否满足等级和属性的判定条件
function c93600443.chkfilter(c,tc)
	local lv=tc:GetLevel()
	local att=tc:GetAttribute()
	return c:IsFaceup() and c:IsLevelBelow(lv) and (c:GetAttribute()&att)==att
end
-- 效果发动时的目标选择与操作信息注册
function c93600443.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c93600443.chkfilter(chkc,e:GetLabelObject()) end
	-- 在发动时，检查自己场上是否存在可以作为此卡效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c93600443.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c93600443.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：包含将对象怪兽送去墓地的处理
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置当前连锁的操作信息：包含从额外卡组特殊召唤怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	e:SetLabelObject(g:GetFirst())
end
-- 效果处理：将对象怪兽送去墓地，并从额外卡组特殊召唤符合条件的「假面英雄」怪兽
function c93600443.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local att=tc:GetAttribute()
	local lv=tc:GetLevel()
	-- 将对象怪兽送去墓地，并检查是否成功送去墓地
	if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只等级比送去墓地的怪兽高且属性相同的「假面英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c93600443.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,att,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续的特殊召唤与送去墓地不视为同时处理
		Duel.BreakEffect()
		-- 将选择的怪兽当作「假面变化」的效果在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,SUMMON_VALUE_MASK_CHANGE,tp,tp,false,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
