--ヴァレット・デトネイター
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有龙族·暗属性连接怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：以自己的魔法与陷阱区域1张龙族·暗属性怪兽卡为对象才能发动。那张卡特殊召唤。这个效果特殊召唤的怪兽不能攻击，效果无效化。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤的自身规则，②以魔陷区龙族·暗属性怪兽为对象的特召效果。
function s.initial_effect(c)
	-- ①：自己场上有龙族·暗属性连接怪兽存在的场合，这张卡可以从手卡特殊召唤。这个卡名的①的方法的特殊召唤1回合只能有1次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：以自己的魔法与陷阱区域1张龙族·暗属性怪兽卡为对象才能发动。那张卡特殊召唤。这个效果特殊召唤的怪兽不能攻击，效果无效化。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.spstg)
	e2:SetOperation(s.spsop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的龙族·暗属性连接怪兽。
function s.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
-- ①的效果特殊召唤的条件：自身怪兽区域有空位，且自己场上存在满足条件的怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在龙族·暗属性连接怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：原本是龙族·暗属性怪兽、处于魔法与陷阱区域（不含场地区）且表侧表示、可以特殊召唤的卡。
function s.sfilter(c,e,tp)
	return (c:GetOriginalType()&TYPE_MONSTER)~=0
		and (c:GetOriginalAttribute()&ATTRIBUTE_DARK)~=0
		and (c:GetOriginalRace()&RACE_DRAGON)~=0
		and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetSequence()<5
end
-- ②的效果的发动准备：检查怪兽区域空位、寻找魔陷区符合条件的目标，并进行取对象和设置操作信息。
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.sfilter(chkc,e,tp) end
	-- 检查发动时自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔法与陷阱区域是否存在可以作为效果对象的龙族·暗属性怪兽卡。
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择魔法与陷阱区域的1张龙族·暗属性怪兽卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②的效果的处理：将作为对象的卡特殊召唤，使其效果无效且不能攻击，并适用“直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤”的限制。
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的那张卡。
	local tc=Duel.GetFirstTarget()
	-- 若该卡仍与连锁相关，则将其以表侧表示特殊召唤。
	if tc:IsRelateToChain() and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 不能攻击
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤的流程。
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.splimit)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内限制从额外卡组特殊召唤非暗属性怪兽的玩家效果。
	Duel.RegisterEffect(e4,tp)
end
-- 限制条件：不能从额外卡组特殊召唤非暗属性怪兽。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
