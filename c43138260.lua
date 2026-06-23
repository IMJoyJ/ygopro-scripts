--エクシーズ・リモーラ
-- 效果：
-- ①：这张卡可以把自己场上2个超量素材取除，从手卡特殊召唤。
-- ②：这张卡的①的方法特殊召唤成功时，以自己墓地2只鱼族·4星怪兽为对象才能发动。那些鱼族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能攻击，效果无效化，也不能作表示形式的变更。把这个效果特殊召唤的怪兽作为超量召唤的素材的场合，不是水属性怪兽的超量召唤不能使用。
function c43138260.initial_effect(c)
	-- 创建一个永续效果，使此卡可以从手牌特殊召唤，条件为自身场上有空位且可以移除2个超量素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c43138260.spcon)
	e1:SetOperation(c43138260.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 创建一个诱发效果，当此卡通过①的方法特殊召唤成功时发动，选择自己墓地2只鱼族·4星怪兽守备表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43138260,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c43138260.spcon2)
	e2:SetTarget(c43138260.sptg2)
	e2:SetOperation(c43138260.spop2)
	c:RegisterEffect(e2)
end
-- 判断是否满足特殊召唤条件：场上是否有空位且是否可以移除2个超量素材
function c43138260.spcon(e,c)
	if c==nil then return true end
	-- 判断场上是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断是否可以移除2个超量素材
		and Duel.CheckRemoveOverlayCard(c:GetControler(),1,0,2,REASON_SPSUMMON)
end
-- 执行移除2个超量素材的操作
function c43138260.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 移除2个超量素材
	Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_SPSUMMON)
end
-- 判断是否满足发动条件：此卡是否为通过①的方法特殊召唤
function c43138260.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 判断目标是否为鱼族·4星怪兽且可以守备表示特殊召唤
function c43138260.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置发动条件：检测是否满足选择2只鱼族·4星墓地怪兽的条件
function c43138260.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43138260.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断场上是否有足够的特殊召唤位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判断墓地是否存在2只符合条件的鱼族·4星怪兽
		and Duel.IsExistingTarget(c43138260.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择2只符合条件的墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c43138260.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 处理特殊召唤效果：获取选择的怪兽并设置限制条件
function c43138260.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选出与当前效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		-- 将怪兽以守备表示特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 设置效果：此怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 设置效果：此怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 设置效果：此怪兽效果在回合结束时无效
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		-- 设置效果：此怪兽不能变更表示形式
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
		-- 设置效果：此怪兽不能作为超量召唤的素材，除非是水属性怪兽
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e5:SetValue(c43138260.xyzlimit)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e5)
		tc=g:GetNext()
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断怪兽是否为水属性，若不是则不能作为超量召唤素材
function c43138260.xyzlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
