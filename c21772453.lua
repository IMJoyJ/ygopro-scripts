--花札衛－紅葉に鹿－
-- 效果：
-- 这张卡不能通常召唤。把「花札卫-枫间鹿-」以外的自己场上1只「花札卫」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以选对方场上1张魔法·陷阱卡破坏。不是的场合，那张卡送去墓地。
function c21772453.initial_effect(c)
	c:EnableReviveLimit()
	-- 把「花札卫-枫间鹿-」以外的自己场上1只「花札卫」怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c21772453.hspcon)
	e1:SetTarget(c21772453.hsptg)
	e1:SetOperation(c21772453.hspop)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以选对方场上1张魔法·陷阱卡破坏。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21772453,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c21772453.target)
	e2:SetOperation(c21772453.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否满足特殊召唤条件的花札卫怪兽
function c21772453.hspfilter(c,tp)
	return c:IsSetCard(0xe6) and not c:IsCode(21772453)
		-- 判断该怪兽是否在自己场上且有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足特殊召唤的条件
function c21772453.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足条件的可解放怪兽
	return Duel.CheckReleaseGroupEx(tp,c21772453.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 设置特殊召唤时选择解放怪兽的处理流程
function c21772453.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足特殊召唤条件的可解放怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c21772453.hspfilter,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作
function c21772453.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽以特殊召唤原因进行解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 设置特殊召唤成功时的抽卡效果目标
function c21772453.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置效果处理的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤函数，用于判断是否为魔法或陷阱卡
function c21772453.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 处理特殊召唤成功后的抽卡与后续效果
function c21772453.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，若抽到卡则继续处理
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取抽卡操作实际抽到的卡片
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 向对方确认抽到的卡片
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			-- 获取对方场上的魔法·陷阱卡组
			local g=Duel.GetMatchingGroup(c21772453.desfilter,tp,0,LOCATION_ONFIELD,nil)
			-- 判断对方场上是否存在魔法·陷阱卡且玩家选择破坏
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(21772453,1)) then  --"是否选对方场上1张魔法·陷阱卡破坏？"
				-- 中断当前效果处理，使后续效果视为错时点
				Duel.BreakEffect()
				local sg=g:Select(tp,1,1,nil)
				-- 显示选中的卡片被选为对象的动画效果
				Duel.HintSelection(sg)
				-- 将选中的魔法·陷阱卡以效果原因破坏
				Duel.Destroy(sg,REASON_EFFECT)
			end
		else
			-- 中断当前效果处理，使后续效果视为错时点
			Duel.BreakEffect()
			-- 将卡片以效果原因送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 将玩家手牌进行洗切
		Duel.ShuffleHand(tp)
	end
end
