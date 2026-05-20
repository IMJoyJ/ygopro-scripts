--エクスクローラー・ニューロゴス
-- 效果：
-- 昆虫族怪兽2只
-- ①：这张卡所连接区的「机怪虫」怪兽不会被战斗破坏，攻击力·守备力上升300，和对方怪兽进行战斗的场合，给与对方的战斗伤害变成2倍。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地2只「机怪虫」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
function c66393507.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：昆虫族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_INSECT),2,2)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地2只「机怪虫」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66393507,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c66393507.spcon)
	e1:SetTarget(c66393507.sptg)
	e1:SetOperation(c66393507.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡所连接区的「机怪虫」怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c66393507.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 和对方怪兽进行战斗的场合，给与对方的战斗伤害变成2倍。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(c66393507.damtg)
	-- 设置战斗伤害变化效果的值，使给与对方的战斗伤害变成2倍
	e5:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e5)
end
-- 效果②的发动条件判定：此卡在场上表侧表示存在，因对方效果离场或被战斗破坏
function c66393507.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤自己墓地中可以里侧守备表示特殊召唤的「机怪虫」怪兽，且墓地中还存在另一只不同名的可特殊召唤的「机怪虫」怪兽
function c66393507.spfilter1(c,e,tp)
	return c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 判定墓地中是否存在另一只与当前选择的卡不同名、且可以里侧守备表示特殊召唤的「机怪虫」怪兽
		and Duel.IsExistingTarget(c66393507.spfilter2,tp,LOCATION_GRAVE,0,1,c,c:GetCode(),e,tp)
end
-- 过滤与第一张选择的卡不同名、且可以里侧守备表示特殊召唤的「机怪虫」怪兽
function c66393507.spfilter2(c,cd,e,tp)
	return not c:IsCode(cd) and c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果②的发动准备（Target）：检查是否受「青眼精灵龙」限制、怪兽区域空位数是否大于1，并选择墓地中2只不同名的「机怪虫」怪兽作为对象
function c66393507.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判定自己场上的主要怪兽区域空位数是否大于1（因为需要特殊召唤2只怪兽）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判定墓地中是否存在满足条件的第1只「机怪虫」怪兽
		and Duel.IsExistingTarget(c66393507.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中第1只满足条件的「机怪虫」怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c66393507.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中第2只不同名的「机怪虫」怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c66393507.spfilter2,tp,LOCATION_GRAVE,0,1,1,tc1,tc1:GetCode(),e,tp)
	g1:Merge(g2)
	-- 设置连锁的操作信息，表示此效果的处理包含将选择的2张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果②的效果处理（Operation）：在满足特殊召唤条件的情况下，将选择的2只怪兽里侧守备表示特殊召唤，并给对方确认
function c66393507.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的主要怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中作为效果对象的卡片组
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
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认里侧特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤此卡所连接区的「机怪虫」怪兽，作为不会被战斗破坏效果的影响对象
function c66393507.indtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0x104)
end
-- 过滤此卡所连接区的、正在与对方怪兽进行战斗的「机怪虫」怪兽，作为伤害翻倍效果的影响对象
function c66393507.damtg(e,c)
	return c:IsSetCard(0x104) and c:GetBattleTarget()~=nil and e:GetHandler():GetLinkedGroup():IsContains(c)
end
