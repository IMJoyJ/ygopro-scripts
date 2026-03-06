--トゥーン・カオス・ソルジャー
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·场上把等级合计直到8以上的卡通怪兽解放的场合可以特殊召唤。
-- ①：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
-- ②：1回合1次，自己场上有「卡通世界」存在的场合，以场上1张卡为对象才能发动。那张卡除外。这个效果发动的回合，这张卡不能攻击。
function c28711704.initial_effect(c)
	-- 记录此卡具有「卡通世界」的效果
	aux.AddCodeList(c,15259703)
	c:EnableReviveLimit()
	-- 从自己的手卡·场上把等级合计直到8以上的卡通怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c28711704.hspcon)
	e1:SetTarget(c28711704.hsptg)
	e1:SetOperation(c28711704.hspop)
	c:RegisterEffect(e1)
	-- 自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c28711704.dircon)
	c:RegisterEffect(e2)
	-- 1回合1次，自己场上有「卡通世界」存在的场合，以场上1张卡为对象才能发动。那张卡除外。这个效果发动的回合，这张卡不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28711704,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c28711704.rmcon)
	e3:SetCost(c28711704.rmcost)
	e3:SetTarget(c28711704.rmtg)
	e3:SetOperation(c28711704.rmop)
	c:RegisterEffect(e3)
end
-- 筛选满足条件的卡通怪兽（控制者或表侧表示）且等级大于等于1
function c28711704.rfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsType(TYPE_TOON) and c:IsLevelAbove(1)
end
-- 检查所选卡片组的等级总和是否大于等于8，且场上存在可用区域，且能从所选卡片中解放
function c28711704.fselect(g,tp)
	-- 设置已选择的卡片组，供后续函数使用
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,8)
		-- 检查场上是否存在可用区域，且能从所选卡片中解放
		and Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,aux.IsInGroup,#g,REASON_SPSUMMON,true,nil,g)
end
-- 判断是否满足特殊召唤条件：从手卡或场上解放满足条件的卡通怪兽
function c28711704.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家可解放的卡片组并筛选出满足条件的卡通怪兽
	local rg=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON):Filter(c28711704.rfilter,c,tp)
	return rg:CheckSubGroup(c28711704.fselect,1,rg:GetCount(),tp)
end
-- 选择满足条件的卡片组用于特殊召唤
function c28711704.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的卡片组并筛选出满足条件的卡通怪兽
	local rg=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON):Filter(c28711704.rfilter,c,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c28711704.fselect,true,1,rg:GetCount(),tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c28711704.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定卡片组从游戏中解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 筛选场上的「卡通世界」
function c28711704.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 筛选场上的卡通怪兽
function c28711704.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 判断是否满足直接攻击条件：己方有「卡通世界」且对方场上无卡通怪兽
function c28711704.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断己方场上是否存在「卡通世界」
	return Duel.IsExistingMatchingCard(c28711704.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判断对方场上是否存在卡通怪兽
		and not Duel.IsExistingMatchingCard(c28711704.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 判断是否满足除外效果发动条件：己方场上存在「卡通世界」
function c28711704.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上是否存在「卡通世界」
	return Duel.IsExistingMatchingCard(c28711704.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置除外效果的费用：本回合未攻击过
function c28711704.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	-- 设置本回合不能攻击的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
end
-- 设置除外效果的目标选择
function c28711704.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 判断是否存在可除外的目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张可除外的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将目标卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外效果
function c28711704.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
