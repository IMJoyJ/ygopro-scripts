--トランスコード・トーカー
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡是互相连接状态的场合，这张卡以及这张卡所互相连接区的怪兽的攻击力上升500，对方不能把那些作为效果的对象。
-- ②：以除「转码语者」外的自己墓地1只连接3以下的电子界族连接怪兽为对象才能发动（这个效果发动的回合，自己不是电子界族怪兽不能特殊召唤）。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
function c46947713.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：效果怪兽2只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	-- ①：这张卡是互相连接状态的场合，这张卡以及这张卡所互相连接区的怪兽的攻击力上升500，对方不能把那些作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(c46947713.atkcon)
	e1:SetTarget(c46947713.atktg)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不能成为对方卡的效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：以除「转码语者」外的自己墓地1只连接3以下的电子界族连接怪兽为对象才能发动（这个效果发动的回合，自己不是电子界族怪兽不能特殊召唤）。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46947713,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,46947713)
	e3:SetCost(c46947713.spcost)
	e3:SetTarget(c46947713.sptg)
	e3:SetOperation(c46947713.spop)
	c:RegisterEffect(e3)
	-- 设置本回合特殊召唤非电子界族怪兽的计数器
	Duel.AddCustomActivityCounter(46947713,ACTIVITY_SPSUMMON,c46947713.counterfilter)
end
-- 判定怪兽是否为表侧表示的电子界族怪兽
function c46947713.counterfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsFaceup()
end
-- 检测本回合是否特殊召唤过非电子界族怪兽，并注册本回合自己不能特殊召唤非电子界族怪兽的限制效果
function c46947713.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定时，检查本回合玩家是否没有特殊召唤过非电子界族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(46947713,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是电子界族怪兽不能特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c46947713.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能特殊召唤非电子界族怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的怪兽必须是电子界族怪兽
function c46947713.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_CYBERSE)
end
-- 判定这张卡是否处于互相连接状态
function c46947713.atkcon(e)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
-- 过滤这张卡以及与这张卡互相连接区的怪兽
function c46947713.atktg(e,c)
	local g=e:GetHandler():GetMutualLinkedGroup()
	return c==e:GetHandler() or g:IsContains(c)
end
-- 过滤自己墓地中除「转码语者」外的连接3以下的电子界族连接怪兽
function c46947713.filter(c,e,tp,zone)
	return c:IsRace(RACE_CYBERSE) and c:IsLinkBelow(3) and c:IsType(TYPE_LINK) and not c:IsCode(46947713)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置特殊召唤效果的判定与对象选择
function c46947713.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46947713.filter(chkc,e,tp,zone) end
	-- 在发动判定时，检查己方场上是否有空置的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查自己墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c46947713.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c46947713.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行：将选择的怪兽在指向的连接区特殊召唤
function c46947713.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将对象怪兽在指向的连接区域表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
