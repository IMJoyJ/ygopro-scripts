--メタル・デビルゾア
-- 效果：
-- 这张卡不能通常召唤。把有「金属化·魔法反射装甲」装备的自己场上1只「恶魔兽灵」解放的场合可以从卡组特殊召唤。
function c50705071.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建一个字段效果，用于特殊召唤的规则判定
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCondition(c50705071.spcon)
	e1:SetTarget(c50705071.sptg)
	e1:SetOperation(c50705071.spop)
	c:RegisterEffect(e1)
end
-- 筛选条件函数：检查目标怪兽是否为恶魔兽灵且装备了金属化·魔法反射装甲，并且场上还有可用区域
function c50705071.spfilter(c,tp)
	return c:IsCode(24311372) and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,68540058)
		-- 确保目标怪兽所在玩家场上存在可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足：检查是否有符合条件的怪兽可以解放
function c50705071.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 调用CheckReleaseGroupEx函数检测是否存在可解放的恶魔兽灵
	return Duel.CheckReleaseGroupEx(tp,c50705071.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 设置特殊召唤的目标选择逻辑：从符合条件的怪兽中选择1只进行解放
function c50705071.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的卡片组，并筛选出满足条件的恶魔兽灵
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c50705071.spfilter,nil,tp)
	-- 向玩家发送提示信息，提示其选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的操作：解放选定的怪兽并洗切卡组
function c50705071.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的卡片以特殊召唤为理由进行解放
	Duel.Release(g,REASON_SPSUMMON)
	-- 将玩家的卡组进行洗切
	Duel.ShuffleDeck(tp)
end
