--紫炎の老中 エニシ
-- 效果：
-- 这张卡不能通常召唤。把自己墓地2只名字带有「六武众」的怪兽从游戏中除外的场合才能特殊召唤。1回合1次，可以选择场上表侧表示存在的1只怪兽破坏。这个效果发动的回合，这张卡不能攻击宣言。
function c38280762.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己墓地2只名字带有「六武众」的怪兽从游戏中除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制除自身规定特殊召唤手续外不能以其他方式特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己墓地2只名字带有「六武众」的怪兽从游戏中除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c38280762.spcon)
	e2:SetTarget(c38280762.sptg)
	e2:SetOperation(c38280762.spop)
	c:RegisterEffect(e2)
	-- 1回合1次，可以选择场上表侧表示存在的1只怪兽破坏。这个效果发动的回合，这张卡不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38280762,0))  --"表侧表示存在的1只怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c38280762.descost)
	e3:SetTarget(c38280762.destg)
	e3:SetOperation(c38280762.desop)
	c:RegisterEffect(e3)
end
-- 特召代价过滤函数：筛选墓地中名字带有「六武众」且可作为代价除外的怪兽
function c38280762.spfilter(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤手续条件检查：确认自己怪兽区有空位且墓地有至少2只可除外的「六武众」怪兽
function c38280762.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否存在可用空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少2只可除外的「六武众」怪兽
		and Duel.IsExistingMatchingCard(c38280762.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤手续选择：让玩家从墓地选择2只「六武众」怪兽（可取消）并暂存到效果对象
function c38280762.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地所有可作为代价除外的「六武众」怪兽
	local g=Duel.GetMatchingGroup(c38280762.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家提示选择要从墓地除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续执行：将选定的2只墓地怪兽除外并释放临时卡片组
function c38280762.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤手续原因将选中的2只怪兽表侧除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 破坏效果代价处理：确认本回合未攻击宣言，并为自身施加本回合不能攻击宣言的誓约限制
function c38280762.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e:GetHandler():RegisterEffect(e1)
end
-- 破坏目标过滤函数：筛选表侧表示存在的怪兽
function c38280762.desfilter(c)
	return c:IsFaceup()
end
-- 破坏效果目标设定：取双方场上1只表侧表示怪兽为对象并登记破坏操作信息
function c38280762.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c38280762.desfilter(chkc) end
	-- 检查双方怪兽区是否存在至少1只表侧表示且可成为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c38280762.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c38280762.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 声明本次效果将破坏选定的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：若对象怪兽仍表侧表示且与效果有联系，则将其破坏
function c38280762.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
