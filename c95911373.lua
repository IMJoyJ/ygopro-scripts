--絶火の魔神ゾロア
-- 效果：
-- 魔法师族调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。从额外卡组把1只「大贤者」怪兽当作装备卡使用给这张卡装备。
-- ②：对方不能把和自己的魔法与陷阱区域的「大贤者」怪兽卡相同种类（融合·同调·超量·连接）的怪兽的效果发动。
-- ③：以自己场上1张「大贤者」卡为对象才能发动。那张卡破坏，这张卡从墓地特殊召唤。
function c95911373.initial_effect(c)
	-- 设置同调召唤手续：魔法师族调整+1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。从额外卡组把1只「大贤者」怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95911373,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c95911373.eqcon)
	e1:SetTarget(c95911373.eqtg)
	e1:SetOperation(c95911373.eqop)
	c:RegisterEffect(e1)
	-- ②：对方不能把和自己的魔法与陷阱区域的「大贤者」怪兽卡相同种类（融合·同调·超量·连接）的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c95911373.actlimit)
	c:RegisterEffect(e2)
	-- ③：以自己场上1张「大贤者」卡为对象才能发动。那张卡破坏，这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95911373,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,95911373)
	e3:SetTarget(c95911373.sptg)
	e3:SetOperation(c95911373.spop)
	c:RegisterEffect(e3)
end
-- 判定触发条件是否为同调召唤成功
function c95911373.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤额外卡组中可以被装备的「大贤者」怪兽
function c95911373.eqfilter(c,ec)
	return c:IsSetCard(0x150) and not c:IsForbidden()
end
-- 效果①（装备额外「大贤者」）的发动准备与合法性检测
function c95911373.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己额外卡组是否存在可装备的「大贤者」怪兽
		and Duel.IsExistingMatchingCard(c95911373.eqfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
end
-- 效果①（装备额外「大贤者」）的效果处理
function c95911373.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查魔法与陷阱区域是否有空位，且自身是否表侧表示存在
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsFaceup()
		and c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从额外卡组选择1只满足条件的「大贤者」怪兽
		local g=Duel.SelectMatchingCard(tp,c95911373.eqfilter,tp,LOCATION_EXTRA,0,1,1,nil,c)
		if g:GetCount()>0 then
			-- 将选中的怪兽作为装备卡装备给此卡
			Duel.Equip(tp,g:GetFirst(),c)
			-- 当作装备卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c95911373.eqlimit)
			e1:SetLabelObject(c)
			g:GetFirst():RegisterEffect(e1)
		end
	end
end
-- 限制装备卡只能装备在当前怪兽上
function c95911373.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤自己魔法与陷阱区域表侧表示的、原本卡片种类与指定种类相同的「大贤者」怪兽卡
function c95911373.cfilter(c,rtype)
	return c:IsFaceup() and c:IsSetCard(0x150) and c:GetOriginalType()&rtype>0
end
-- 效果②（封锁对方同种怪兽效果发动）的限制条件判定
function c95911373.actlimit(e,re,rp)
	local tp=e:GetHandlerPlayer()
	local rtype=bit.band(re:GetHandler():GetType(),TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	-- 判定发动的效果是否为怪兽效果，且该怪兽的原本种类是否与自己魔陷区表侧表示的「大贤者」怪兽卡相同
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(c95911373.cfilter,tp,LOCATION_SZONE,0,1,nil,rtype)
end
-- 过滤自己场上表侧表示的「大贤者」卡，且该卡被破坏后能腾出怪兽区域空位
function c95911373.desfilter(c,tp)
	-- 判定卡片是否为自己场上表侧表示的「大贤者」卡，且其离开场上后自己有可用的怪兽区域
	return c:IsFaceup() and c:IsSetCard(0x150) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果③（破坏场上「大贤者」并墓地特召）的发动准备与合法性检测
function c95911373.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c95911373.desfilter(chkc,tp) end
	-- 检查自己场上是否存在可作为破坏对象的「大贤者」卡，且此卡是否能从墓地特殊召唤
	if chk==0 then return Duel.IsExistingTarget(c95911373.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择自己场上1张「大贤者」卡作为效果对象
	local g=Duel.SelectTarget(tp,c95911373.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置连锁信息：包含破坏选中的卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息：包含特殊召唤此卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③（破坏场上「大贤者」并墓地特召）的效果处理
function c95911373.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡成功被效果破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			-- 将此卡从墓地表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
