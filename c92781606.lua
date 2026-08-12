--エクスクローラー・クオリアーク
-- 效果：
-- 「机怪虫」怪兽2只
-- ①：自己场上的「机怪虫」怪兽数量对应的以下适用。
-- ●2只以上：自己场上的怪兽的攻击力·守备力上升300。
-- ●4只以上：对方在战斗阶段中不能把效果发动。
-- ●6只以上：自己怪兽可以直接攻击。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地2只「机怪虫」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
function c92781606.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：需要2只「机怪虫」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x104),2,2)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地2只「机怪虫」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92781606,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c92781606.spcon)
	e1:SetTarget(c92781606.sptg)
	e1:SetOperation(c92781606.spop)
	c:RegisterEffect(e1)
	-- ●2只以上：自己场上的怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(300)
	e2:SetCondition(c92781606.effcon)
	e2:SetLabel(2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ●4只以上：对方在战斗阶段中不能把效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetTargetRange(0,1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetLabel(4)
	e4:SetCondition(c92781606.actcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ●6只以上：自己怪兽可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetLabel(6)
	e5:SetCondition(c92781606.effcon)
	c:RegisterEffect(e5)
end
-- 定义效果②的发动条件：表侧表示的这张卡因对方的效果从场上离开，或者被战斗破坏
function c92781606.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤墓地中可以里侧守备表示特殊召唤的「机怪虫」怪兽，且墓地中还存在另一只不同名的「机怪虫」怪兽
function c92781606.spfilter1(c,e,tp)
	return c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 检查墓地中是否存在另一只与第一只选择的怪兽卡名不同的「机怪虫」怪兽
		and Duel.IsExistingTarget(c92781606.spfilter2,tp,LOCATION_GRAVE,0,1,c,c:GetCode(),e,tp)
end
-- 过滤墓地中与第一只选择的怪兽卡名不同、且可以里侧守备表示特殊召唤的「机怪虫」怪兽
function c92781606.spfilter2(c,cd,e,tp)
	return not c:IsCode(cd) and c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 定义效果②的发动准备（检查阶段）：确认没有受到限制特殊召唤的效果影响、自己场上有2个以上的空怪兽位，且墓地有符合条件的怪兽
function c92781606.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查墓地中是否存在至少一只符合条件的「机怪虫」怪兽作为第一个对象
		and Duel.IsExistingTarget(c92781606.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送选择特殊召唤卡片的消息提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中第一只「机怪虫」怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c92781606.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	-- 给玩家发送选择特殊召唤卡片的消息提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中第二只与第一只不同名的「机怪虫」怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c92781606.spfilter2,tp,LOCATION_GRAVE,0,1,1,tc1,tc1:GetCode(),e,tp)
	g1:Merge(g2)
	-- 设置当前连锁的操作信息：包含特殊召唤2只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 定义效果②的效果处理：将选中的2只「机怪虫」怪兽在自己场上里侧守备表示特殊召唤
function c92781606.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中作为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or ft<=0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<g:GetCount() then
		-- 给玩家发送选择特殊召唤卡片的消息提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	if g:GetCount()>0 then
		-- 将目标怪兽在自己场上里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认里侧特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己场上表侧表示的「机怪虫」怪兽
function c92781606.effilter(c)
	return c:IsFaceup() and c:IsSetCard(0x104)
end
-- 定义效果①的适用条件：检查自己场上的「机怪虫」怪兽数量是否达到指定数值
function c92781606.effcon(e)
	-- 返回自己场上表侧表示的「机怪虫」怪兽数量是否大于或等于设定的阈值
	return Duel.GetMatchingGroupCount(c92781606.effilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)>=e:GetLabel()
end
-- 定义对方在战斗阶段中不能发动效果的条件：自己场上的「机怪虫」怪兽在4只以上，且当前处于战斗阶段
function c92781606.actcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return c92781606.effcon(e) and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
