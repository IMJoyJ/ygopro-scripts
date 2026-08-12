--海竜神－ネオダイダロス
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的1只「海龙-泰达路斯」解放的场合才能特殊召唤。可以通过把自己场上存在的「海」送去墓地，这张卡以外的双方的手卡·场上的卡全部送去墓地。
function c10485110.initial_effect(c)
	-- 注册卡片记载的「海」卡片密码事实
	aux.AddCodeList(c,22702055)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定值为不可进行通常的特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己场上存在的1只「海龙-泰达路斯」解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c10485110.spcon)
	e2:SetTarget(c10485110.sptg)
	e2:SetOperation(c10485110.spop)
	c:RegisterEffect(e2)
	-- 可以通过把自己场上存在的「海」送去墓地，这张卡以外的双方的手卡·场上的卡全部送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10485110,0))  --"送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c10485110.cost)
	e3:SetTarget(c10485110.target)
	e3:SetOperation(c10485110.operation)
	c:RegisterEffect(e3)
end
-- 过滤场上满足特殊召唤解放条件的「海龙-泰达路斯」且能提供空余怪兽区域的过滤函数
function c10485110.spfilter(c,tp)
	-- 判定被解放卡片是否为「海龙-泰达路斯」且其离场后可供腾出特殊召唤的格子位置
	return c:IsCode(37721209) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的允许发动条件判定函数
function c10485110.spcon(e,c)
	if c==nil then return true end
	-- 判定玩家场上是否存在至少1只满足特殊召唤条件的「海龙-泰达路斯」可供解放
	return Duel.CheckReleaseGroupEx(c:GetControler(),c10485110.spfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 特殊召唤规则的解放目标选取与存储函数
function c10485110.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有可解放且满足特殊召唤条件的「海龙-泰达路斯」卡片
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10485110.spfilter,nil,tp)
	-- 给玩家显示选择要解放卡片的系统提示文字
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的实际解放Cost执行函数
function c10485110.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的「海龙-泰达路斯」作为特殊召唤原因进行解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤场上表侧表示「海」且能作为Cost送去墓地卡片的过滤函数
function c10485110.cfilter(c)
	return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGraveAsCost()
end
-- 起动效果的发动Cost判定与处理逻辑（将场上的「海」送去墓地）
function c10485110.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否存在可以送去墓地的表侧表示的「海」以进行效果发动
	if chk==0 then return Duel.IsExistingMatchingCard(c10485110.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 给玩家显示选择送墓卡片的系统提示文字
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从场上选择1张符合Cost过滤条件的「海」
	local g=Duel.SelectMatchingCard(tp,c10485110.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的「海」以Cost为原因送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 起动效果的发动目标判定与操作信息注册（除自身外双方手牌场上所有卡送去墓地）
function c10485110.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定除自身外双方手牌及场上是否存在至少1张卡片以满足发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0xe,0xe,1,e:GetHandler()) end
	-- 获取除自身外双方手牌和场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0xe,0xe,e:GetHandler())
	-- 向系统注册效果分类信息为：送去墓地，对象为上述除自身外的所有卡片
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 起动效果的效果处理逻辑（将自身以外的双方手牌与场上的卡全部送去墓地）
function c10485110.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取除成功处理效果的自身外双方手牌及场上的所有卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0xe,0xe,aux.ExceptThisCard(e))
	-- 将获取的全部卡片以效果原因为由送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
