--ドラゴニックP
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：场上的「龙剑士」怪兽的攻击力·守备力上升300。
-- ②：自己场上的龙族「龙剑士」怪兽把效果发动的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：场上的这张卡被破坏的场合才能发动。从卡组选1只「龙剑士」怪兽或者「龙魔王」怪兽加入手卡或特殊召唤。
function c71817640.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「龙剑士」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的对象为「龙剑士」怪兽（字段为0xc7）
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xc7))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：自己场上的龙族「龙剑士」怪兽把效果发动的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(71817640,0))  --"场上卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,71817640)
	e4:SetCondition(c71817640.descon)
	e4:SetTarget(c71817640.destg)
	e4:SetOperation(c71817640.desop)
	c:RegisterEffect(e4)
	-- ③：场上的这张卡被破坏的场合才能发动。从卡组选1只「龙剑士」怪兽或者「龙魔王」怪兽加入手卡或特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,71817641)
	e5:SetCondition(c71817640.tscon)
	e5:SetTarget(c71817640.tstg)
	e5:SetOperation(c71817640.tsop)
	c:RegisterEffect(e5)
end
-- 效果②的发动条件：自己场上的龙族「龙剑士」怪兽在怪兽区域发动了效果
function c71817640.descon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rp==tp and rc:IsSetCard(0xc7) and rc:IsRace(RACE_DRAGON)
		and rc:IsLocation(LOCATION_MZONE) and re:GetActivateLocation()==LOCATION_MZONE
end
-- 效果②的靶向/发动准备：检查场上是否存在可作为对象的卡，并进行取对象和设置破坏操作信息
function c71817640.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在发动阶段（chk==0）检查场上是否存在至少1张可以成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息，表明此效果将破坏所选的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：破坏作为对象的卡
function c71817640.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡原本在场上且被破坏
function c71817640.tscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果③的卡片过滤条件：卡组中的「龙剑士」或「龙魔王」怪兽，且满足能加入手卡或能特殊召唤的条件
function c71817640.tsfilter(c,e,tp)
	if not (c:IsSetCard(0xc7,0xda) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取玩家场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果③的发动准备：检查卡组中是否存在满足条件的怪兽，并设置检索和特殊召唤的操作信息
function c71817640.tstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在至少1只满足条件的「龙剑士」或「龙魔王」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c71817640.tsfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表明此效果可能从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁的操作信息，表明此效果可能从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理：从卡组选1只符合条件的怪兽，由玩家选择加入手卡或特殊召唤
function c71817640.tsop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选择1只满足条件的「龙剑士」或「龙魔王」怪兽
	local g=Duel.SelectMatchingCard(tp,c71817640.tsfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取玩家场上可用的怪兽区域空格数，用于判断是否能进行特殊召唤
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否只能加入手卡，或者在可以特召且有空位的情况下，玩家主动选择“加入手卡”（选项0）
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
