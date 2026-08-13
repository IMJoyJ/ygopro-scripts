--炎獣の影霊衣－セフィラエグザ
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己不是「影灵衣」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 「炎兽之影灵衣-神数艾可萨」的怪兽效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，「炎兽之影灵衣-神数艾可萨」以外的自己的怪兽区域·灵摆区域的「影灵衣」卡或者「神数」卡被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
function c20773176.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆召唤及作为灵摆卡发动。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「影灵衣」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c20773176.splimit)
	c:RegisterEffect(e2)
	-- 「炎兽之影灵衣-神数艾可萨」的怪兽效果1回合只能使用1次。①：这张卡在手卡·墓地存在，「炎兽之影灵衣-神数艾可萨」以外的自己的怪兽区域·灵摆区域的「影灵衣」卡或者「神数」卡被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,20773176)
	e3:SetCondition(c20773176.condition)
	e3:SetTarget(c20773176.target)
	e3:SetOperation(c20773176.operation)
	c:RegisterEffect(e3)
end
-- 灵摆召唤限制的判定函数：若灵摆召唤的怪兽是「影灵衣」或「神数」则不限制；否则若该次召唤为灵摆召唤则禁止。
function c20773176.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0xb4,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 被破坏怪兽的筛选条件：必须是被战斗或效果破坏的、属于「影灵衣」或「神数」、不是本卡（20773176）、原控制者为发动玩家、且破坏前位于表侧表示的主要怪兽区或灵摆区。
function c20773176.filter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsSetCard(0xb4,0xc4) and not c:IsCode(20773176)
		and c:IsPreviousControler(tp)
		and ((c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP))
		or c:IsPreviousLocation(LOCATION_PZONE))
end
-- 发动条件：在本次被破坏的怪兽集合中存在至少1张满足上述筛选条件的卡。
function c20773176.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20773176.filter,1,nil,tp)
end
-- 发动合法检测：自己场上存在可用的主要怪兽区，且这张卡自身可被特殊召唤。
function c20773176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格，用于判断能否发动特召效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，将本效果标记为特殊召唤类别，并指定特殊召唤的对象为本卡，数量1；用于给其他卡片效果提供连锁判定依据。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：获取本卡，若它仍与当前效果保持关联，则将其特殊召唤。
function c20773176.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将本卡以表侧表示特殊召唤到自己场上（按常规检查召唤条件与苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
