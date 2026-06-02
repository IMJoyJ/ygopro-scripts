--燦幻封炉
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己的龙族·炎属性怪兽的战斗让怪兽被破坏时，以那1只破坏的怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。
-- ②：对方结束阶段，支付1000基本分，以自己墓地1张「灿幻」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片发动、效果①（自己龙族·炎属性怪兽战斗破坏怪兽时守备表示特召被破坏怪兽）和效果②（对方结束阶段支付1000基本分盖放墓地「灿幻」魔陷）的效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己的龙族·炎属性怪兽的战斗让怪兽被破坏时，以那1只破坏的怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方结束阶段，支付1000基本分，以自己墓地1张「灿幻」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合除外。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己的龙族·炎属性怪兽的战斗让怪兽被破坏时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家自身正处于战斗中的怪兽
	local a=Duel.GetBattleMonster(tp)
	return a and (a:IsLocation(LOCATION_MZONE) and a:IsRace(RACE_DRAGON) and a:IsAttribute(ATTRIBUTE_FIRE)
		or not a:IsLocation(LOCATION_MZONE) and a:IsPreviousControler(tp)
			and a:GetPreviousRaceOnField()&RACE_DRAGON~=0
			and a:GetPreviousAttributeOnField()&ATTRIBUTE_FIRE~=0)
end
-- 过滤条件：非衍生物、属于怪兽卡，且可以成为效果对象并能以守备表示特殊召唤的卡
function s.tgfilter(c,e,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsFaceupEx() and c:IsType(TYPE_MONSTER)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备：检查主要怪兽区域空格并筛选符合条件的怪兽，选择1只被破坏的怪兽作为效果的对象，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=eg:Filter(s.tgfilter,nil,e,tp)
	-- 检查自身场上是否有可用的怪兽区域空格，并且存在至少1个可以被选择的对象怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 end
	local bc=g:GetFirst()
	if g:GetCount()>1 then
		bc=g:FilterSelect(tp,s.tgfilter,1,1,nil,e,tp):GetFirst()
	end
	-- 将选中的被破坏怪兽设置为当前效果的对象
	Duel.SetTargetCard(bc)
	-- 设置当前效果处理的操作信息为特殊召唤该被破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 效果①的效果处理：获取对象怪兽，在其仍符合对象关系且不受王家长眠之谷影响时，将其在自己场上守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为效果对象的被破坏怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，且不受王家长眠之谷的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件：检查当前是否为对方的回合
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果②的消耗检查与支付：检查并支付1000点基本分
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家自身的基本分是否足够支付1000点
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000点基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤条件：自己墓地中可以盖放的「灿幻」魔法·陷阱卡
function s.sfilter(c)
	return c:IsSetCard(0x1a9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的发动准备：检查墓地是否有可盖放的「灿幻」魔陷，选择1张作为对象，并设置将卡片移出墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc) end
	-- 检查自己墓地中是否存在至少1张符合盖放条件的「灿幻」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示信息：“请选择要盖放的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地中1张符合盖放条件的「灿幻」魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的对象卡片移出墓地，数量为1
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②的效果处理：获取对象卡片，在其仍符合对象关系且不受王家长眠之谷影响时将其盖放到自己场上，并添加离场时除外的限制
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为效果对象的「灿幻」魔法·陷阱卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡片是否仍与效果相关，且不受王家长眠之谷的影响，并在自己场上盖放
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SSet(tp,tc) then
		-- 这个效果盖放的卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1)
	end
end
