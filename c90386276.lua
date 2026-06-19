--罪なき罪宝
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●以自己的墓地·除外状态的1只「迪亚贝尔」怪兽为对象才能发动。选自己1张手卡丢弃，作为对象的怪兽特殊召唤。
-- ●以自己的魔法与陷阱区域1张表侧表示的怪兽卡为对象才能发动。那张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片自身的效果：包含卡片发动（e1）和在魔陷区发动的2速效果（e2）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：可以从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果1的过滤函数：判断卡片是否为可以特殊召唤的「迪亚贝尔」怪兽，且手牌中存在可以丢弃的卡
function s.spfilter1(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 过滤条件：是「迪亚贝尔」怪兽，且手牌中存在可以丢弃的卡（不包括自身）
		and c:IsSetCard(0x19b) and Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,LOCATION_HAND,0,e:GetHandler(),REASON_EFFECT)>0
end
-- 效果2的过滤函数：判断卡片是否为在魔法与陷阱区域表侧表示存在且可以特殊召唤的怪兽卡
function s.spfilter2(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLocation(LOCATION_SZONE)
end
-- 效果发动时的目标选择与处理分支：根据玩家选择的效果分支，进行对应的取对象和操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否有空余的怪兽区域
	local b0=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 判断是否可以发动效果1：有怪兽空位，且墓地或除外状态存在满足条件的「迪亚贝尔」怪兽
	local b1=b0 and Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	-- 判断是否可以发动效果2：有怪兽空位，且魔法与陷阱区域存在满足条件的表侧表示怪兽卡
	local b2=b0 and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_SZONE,0,1,nil,e,tp)
	if chkc then
		if e:GetLabel()==1 then
			return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter1(chkc,e,tp)
		elseif e:GetLabel()==2 then
			return chkc:IsLocation(LOCATION_SZONE) and s.spfilter2(chkc,e,tp)
		end
	end
	if chk==0 then return b1 or b2 end
	-- 让玩家选择要发动的效果分支
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,0),1},  --"以墓地·除外状态的卡为对象"
		{b2,aux.Stringid(id,1),2})  --"以魔法与陷阱区域的卡为对象"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		-- 设置特殊召唤的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择魔法与陷阱区域的1张表侧表示怪兽卡作为对象
		local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
		-- 设置特殊召唤的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果处理函数：根据选择的分支，执行丢弃手牌（若为效果1）并特殊召唤对象怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡
	local tc=Duel.GetFirstTarget()
	-- 如果选择的是效果1，则选自己1张手卡丢弃。若丢弃失败则不进行后续处理
	if e:GetLabel()==1 and Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT,nil)==0 then return end
	if not tc:IsRelateToEffect(e) then return end
	-- 检查对象卡是否受到「王家之谷」的影响
	if aux.NecroValleyFilter()(tc) then
		-- 将作为对象的怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
