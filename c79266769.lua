--闇鋼龍 ダークネスメタル
-- 效果：
-- 相同种族·属性的效果怪兽2只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：以1只自己墓地的怪兽或者除外的自己怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，从场上离开的场合回到持有者卡组最下面。这个效果的发动后，直到回合结束时自己不能把连接怪兽特殊召唤。
function c79266769.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：需要2只以上的怪兽作为素材，且素材必须是效果怪兽，并满足额外的检测条件（相同种族·属性）
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,nil,c79266769.spcheck)
	-- ①：以1只自己墓地的怪兽或者除外的自己怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，从场上离开的场合回到持有者卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79266769,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,79266769)
	e1:SetTarget(c79266769.sptg)
	e1:SetOperation(c79266769.spop)
	c:RegisterEffect(e1)
end
-- 连接素材的额外检测函数：检查用于连接召唤的素材怪兽是否具有相同的种族和属性
function c79266769.spcheck(g)
	-- 检查素材怪兽组的种族是否全部相同，且属性是否全部相同
	return aux.SameValueCheck(g,Card.GetLinkRace) and aux.SameValueCheck(g,Card.GetLinkAttribute)
end
-- 过滤函数：筛选自己墓地或除外状态的、可以守备表示特殊召唤到此卡连接区的怪兽
function c79266769.filter(c,e,tp,zone)
	return (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 效果①的发动准备与目标选择：获取此卡的连接区域，并判定是否存在可选择的合法对象
function c79266769.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c79266769.filter(chkc,e,tp,zone) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地或除外区是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingTarget(c79266769.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地或除外区的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c79266769.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,zone)
	-- 设置当前连锁的操作信息：包含特殊召唤分类，操作对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将选择的对象怪兽在连接区守备表示特殊召唤，并适用效果无效化和离场回卡组最底下的限制
function c79266769.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	if tc and tc:IsRelateToEffect(e) and zone~=0
		-- 尝试将对象怪兽在作为此卡连接区的自己场上以表侧守备表示进行特殊召唤的单步处理
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e2)
		-- 从场上离开的场合回到持有者卡组最下面
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_DECKBOT)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤的流程处理
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不能把连接怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTargetRange(1,0)
	e4:SetTarget(c79266769.splimit)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能特殊召唤连接怪兽的限制效果
	Duel.RegisterEffect(e4,tp)
end
-- 限制效果的过滤函数：限制特殊召唤的怪兽类型为连接怪兽
function c79266769.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsType(TYPE_LINK)
end
