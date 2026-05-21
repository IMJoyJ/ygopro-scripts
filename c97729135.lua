--にらみ合い
-- 效果：
-- ①：自己在额外怪兽区域把怪兽特殊召唤时，以对方的主要怪兽区域1只怪兽为对象才能发动。那只对方怪兽向和那自己的额外怪兽区域的怪兽相同纵列的对方的主要怪兽区域移动。
-- ②：对方在额外怪兽区域把怪兽特殊召唤时，以自己的主要怪兽区域1只怪兽为对象才能发动。那只自己怪兽向和那对方的额外怪兽区域的怪兽相同纵列的自己的主要怪兽区域移动。
function c97729135.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己在额外怪兽区域把怪兽特殊召唤时，以对方的主要怪兽区域1只怪兽为对象才能发动。那只对方怪兽向和那自己的额外怪兽区域的怪兽相同纵列的对方的主要怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97729135,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c97729135.mvcon1)
	e2:SetTarget(c97729135.mvtg1)
	e2:SetOperation(c97729135.mvop1)
	c:RegisterEffect(e2)
	-- ②：对方在额外怪兽区域把怪兽特殊召唤时，以自己的主要怪兽区域1只怪兽为对象才能发动。那只自己怪兽向和那对方的额外怪兽区域的怪兽相同纵列的自己的主要怪兽区域移动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97729135,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c97729135.mvcon2)
	e3:SetTarget(c97729135.mvtg2)
	e3:SetOperation(c97729135.mvop2)
	c:RegisterEffect(e3)
end
-- 过滤在额外怪兽区域特殊召唤的怪兽
function c97729135.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:GetSequence()>=5
end
-- 检查是否自己在额外怪兽区域把怪兽特殊召唤
function c97729135.mvcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c97729135.cfilter,1,nil,tp)
end
-- 过滤主要怪兽区域的怪兽
function c97729135.mvfilter(c)
	return c:GetSequence()<5
end
-- 效果①的靶向：计算自己特殊召唤的额外怪兽同纵列的对方主要怪兽区域，并确认对方主要怪兽区域有可选择的怪兽且该纵列有空位
function c97729135.mvtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=0
	local lg=eg:Filter(c97729135.cfilter,nil,tp)
	-- 遍历本次特殊召唤到额外怪兽区域的怪兽
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,1-tp))
	end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c97729135.mvfilter(chkc) end
	-- 检查对方主要怪兽区域是否存在可选为对象的主要怪兽
	if chk==0 then return Duel.IsExistingTarget(c97729135.mvfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 并且对方场上与该额外怪兽相同纵列的主要怪兽区域有空位
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 end
	-- 提示玩家选择要移动的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(97729135,2))  --"请选择要移动到的位置"
	-- 选择对方主要怪兽区域的1只怪兽作为对象
	Duel.SelectTarget(tp,c97729135.mvfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的操作：计算可移动的纵列区域，验证对象怪兽和空位状态
function c97729135.mvop1(e,tp,eg,ep,ev,re,r,rp)
	local zone=0
	local lg=eg:Filter(c97729135.cfilter,nil,tp)
	-- 遍历本次特殊召唤到额外怪兽区域的怪兽，计算其对应的纵列区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,1-tp))
	end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(tp)
		-- 如果对方相同纵列的主要怪兽区域没有空位，则不处理
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0,zone)<=0 then return end
	local flag=bit.bxor(zone,0xff)*0x10000
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家在对方场上相同纵列的可用主要怪兽区域中选择1个格子
	local s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,flag)/0x10000
	local nseq=math.log(s,2)
	-- 将对象怪兽移动到选择的格子
	Duel.MoveSequence(tc,nseq)
end
-- 检查是否对方在额外怪兽区域把怪兽特殊召唤
function c97729135.mvcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c97729135.cfilter,1,nil,1-tp)
end
-- 效果②的靶向：计算对方特殊召唤的额外怪兽同纵列的自己主要怪兽区域，并确认自己主要怪兽区域有可选择的怪兽且该纵列有空位
function c97729135.mvtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=0
	local lg=eg:Filter(c97729135.cfilter,nil,1-tp)
	-- 遍历本次对方特殊召唤到额外怪兽区域的怪兽
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c97729135.mvfilter(chkc) end
	-- 检查自己主要怪兽区域是否存在可选为对象的主要怪兽
	if chk==0 then return Duel.IsExistingTarget(c97729135.mvfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且自己场上与该额外怪兽相同纵列的主要怪兽区域有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 end
	-- 提示玩家选择要移动的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(97729135,2))  --"请选择要移动到的位置"
	-- 选择自己主要怪兽区域的1只怪兽作为对象
	Duel.SelectTarget(tp,c97729135.mvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的操作：计算可移动的纵列区域，验证对象怪兽和空位状态
function c97729135.mvop2(e,tp,eg,ep,ev,re,r,rp)
	local zone=0
	local lg=eg:Filter(c97729135.cfilter,nil,1-tp)
	-- 遍历本次对方特殊召唤到额外怪兽区域的怪兽，计算其对应的纵列区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp)
		-- 如果自己相同纵列的主要怪兽区域没有空位，则不处理
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)<=0 then return end
	local flag=bit.bxor(zone,0xff)
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家在自己场上相同纵列的可用主要怪兽区域中选择1个格子
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
	local nseq=math.log(s,2)
	-- 将对象怪兽移动到选择的格子
	Duel.MoveSequence(tc,nseq)
end
