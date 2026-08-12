--魔救の輝跡
-- 效果：
-- 包含同调怪兽的效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合或者这张卡所连接区有怪兽特殊召唤的场合，以自己的场上·墓地1只怪兽为对象才能发动。把持有和那只怪兽相同等级的1只「奇石衍生物」（岩石族·光·攻/守0）在自己场上特殊召唤。
-- ②：这张卡以外的场上的怪兽的效果发动时才能发动。那只怪兽回到卡组最上面。
local s,id,o=GetID()
-- 初始化卡片效果：注册连接召唤手续，并注册特殊召唤衍生物的诱发效果（连接召唤时与所连接区特殊召唤时两个版本）以及将怪兽弹回卡组的诱发即时效果
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只效果怪兽为连接素材，且素材中需包含同调怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2,s.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡连接召唤的场合或者这张卡所连接区有怪兽特殊召唤的场合，以自己的场上·墓地1只怪兽为对象才能发动。把持有和那只怪兽相同等级的1只「奇石衍生物」（岩石族·光·攻/守0）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcon1)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tkcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡以外的场上的怪兽的效果发动时才能发动。那只怪兽回到卡组最上面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 连接素材的额外检查：要求连接素材组中至少包含1只同调怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_SYNCHRO)
end
-- ①效果的发动条件1：这张卡是连接召唤成功的场合
function s.tkcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：判断该怪兽是否在这张卡的所连接区（连接状态怪兽组）内
function s.cfilter(c,lg)
	return lg:IsContains(c)
end
-- ①效果的发动条件2：特殊召唤成功的怪兽中存在位于这张卡所连接区的怪兽
function s.tkcon2(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(s.cfilter,1,nil,lg)
end
-- 对象过滤函数：对象为自己场上·墓地表侧表示且持有等级的怪兽，且自己能特殊召唤与该怪兽相同等级的「奇石衍生物」
function s.tfilter(c,tp)
	return c:IsFaceupEx() and c:IsLevelAbove(1)
		-- 检查自己能否特殊召唤持有与该怪兽相同等级的「奇石衍生物」（岩石族·光·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,c:GetLevel(),RACE_ROCK,ATTRIBUTE_LIGHT)
end
-- ①效果的对象选择处理：检查自己怪兽区域有无空位，并确认自己场上·墓地存在可作为对象的满足条件的怪兽
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.tfilter(chkc,tp) end
	-- 发动可能性的检查：自己怪兽区域必须有1个以上的可使用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己场上·墓地存在1只能成为效果对象的满足条件的怪兽
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 向玩家发送「请选择效果的对象」的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己的场上·墓地选择1只满足条件的怪兽作为效果对象（优先从场上选择）
	aux.SelectTargetFromFieldFirst(tp,s.tfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：宣言将处理1次衍生物相关操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：宣言将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①效果的处理：取对象怪兽，确认其仍有效且自己场上有空位并能特殊召唤衍生物后，特殊召唤「奇石衍生物」并将其等级变为与对象怪兽相同
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽仍与连锁关联、为表侧表示，且自己怪兽区域有空位
	if tc:IsRelateToChain() and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否特殊召唤持有与对象怪兽相同等级的「奇石衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,tc:GetLevel(),RACE_ROCK,ATTRIBUTE_LIGHT) then
		-- 在自己场上生成1只「奇石衍生物」
		local token=Duel.CreateToken(tp,id+o)
		-- 以表侧表示特殊召唤那只衍生物（特殊召唤的分步处理）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 把持有和那只怪兽相同等级的1只「奇石衍生物」（岩石族·光·攻/守0）在自己场上特殊召唤。②：这张卡以外的场上的怪兽的效果发动时才能发动。那只怪兽回到卡组最上面。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成衍生物的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
-- ②效果的发动条件：发动效果的怪兽在这张卡以外的场上、是该效果的效果怪兽（即这张卡以外的场上的怪兽的效果发动时）
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return rc:IsOnField() and rc:IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER) and c~=rc
end
-- ②效果的目标处理：确认那只怪兽可以回到卡组，并设置回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToDeck() end
	-- 设置操作信息：宣言将把发动效果的那只怪兽（1只）回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
end
-- ②效果的处理：若那只怪兽仍与连锁关联且位于怪兽区域，则将其回到卡组最上面
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) and rc:IsLocation(LOCATION_MZONE) then
		-- 将那只怪兽以效果原因回到持有者的卡组最上面
		Duel.SendtoDeck(rc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
