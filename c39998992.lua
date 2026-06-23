--エクスクローラー・シナプシス
-- 效果：
-- 地属性怪兽2只
-- ①：这张卡所连接区的「机怪虫」怪兽不会被战斗破坏，攻击力·守备力上升300，同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地2只「机怪虫」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
function c39998992.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2只地属性怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_EARTH),2,2)
	-- 表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地2只「机怪虫」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39998992,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c39998992.spcon)
	e1:SetTarget(c39998992.sptg)
	e1:SetOperation(c39998992.spop)
	c:RegisterEffect(e1)
	-- 这张卡所连接区的「机怪虫」怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c39998992.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	c:RegisterEffect(e5)
end
-- 表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地2只「机怪虫」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
function c39998992.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 筛选墓地中的「机怪虫」怪兽，满足特殊召唤条件且能配合第二个过滤器
function c39998992.spfilter1(c,e,tp)
	return c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 确保在墓地中存在满足条件的第二只「机怪虫」怪兽
		and Duel.IsExistingTarget(c39998992.spfilter2,tp,LOCATION_GRAVE,0,1,c,c:GetCode(),e,tp)
end
-- 筛选墓地中非同名的「机怪虫」怪兽，满足特殊召唤条件
function c39998992.spfilter2(c,cd,e,tp)
	return not c:IsCode(cd) and c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 检测是否满足发动条件，包括未受青眼精灵龙效果影响、场上存在召唤空间、墓地存在符合条件的怪兽
function c39998992.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上是否有足够的召唤空间
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测墓地是否存在符合条件的「机怪虫」怪兽
		and Duel.IsExistingTarget(c39998992.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择第一只「机怪虫」怪兽作为特殊召唤对象
	local g1=Duel.SelectTarget(tp,c39998992.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择第二只「机怪虫」怪兽作为特殊召唤对象
	local g2=Duel.SelectTarget(tp,c39998992.spfilter2,tp,LOCATION_GRAVE,0,1,1,tc1,tc1:GetCode(),e,tp)
	g1:Merge(g2)
	-- 设置操作信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 处理特殊召唤操作，包括判断召唤数量和召唤位置
function c39998992.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的召唤空间数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中目标卡组信息
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or ft<=0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<g:GetCount() then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	if g:GetCount()>0 then
		-- 将目标卡组特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认特殊召唤的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断目标怪兽是否在连接区且为「机怪虫」怪兽
function c39998992.indtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0x104)
end
