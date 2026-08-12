--魔力到達
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：除「魔力到达」外的1张效果文本有「魔力指示物」记述的卡从自己的卡组·墓地加入手卡。自己场上有7星以上的「恩底弥翁」怪兽卡存在的场合，可以再让以下效果适用。
-- ●自己场上的魔力指示物任意数量取除，那个数量的对方场上的表侧表示卡的效果无效并破坏。
local s,id,o=GetID()
-- 注册发动效果：分类为加入手卡·卡组检索·破坏·效果无效，类型为魔法卡发动的自由时点效果，并设置同名卡1回合只能发动1张的誓约次数限制
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：除「魔力到达」外的1张效果文本有「魔力指示物」记述的卡从自己的卡组·墓地加入手卡。自己场上有7星以上的「恩底弥翁」怪兽卡存在的场合，可以再让以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.mentioned_counter={
	[0x1]=true,
}
-- 定义辅助函数：判断一张卡的效果文本是否记述了指定种类的指示物
function Auxiliary.HasMentionedCounter(c,counter)
	return c.mentioned_counter and c.mentioned_counter[counter] or false
end
-- 定义检索过滤条件：除「魔力到达」外、效果文本记述了「魔力指示物」且可以加入手卡的卡
function s.thfilter(c)
	-- 返回过滤结果：不是「魔力到达」本身、效果文本记述了「魔力指示物」（0x1）且可以加入手卡
	return not c:IsCode(id) and Auxiliary.HasMentionedCounter(c,0x1) and c:IsAbleToHand()
end
-- 发动对象检查函数：确认卡组·墓地存在可检索的卡，并设置加入手卡的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组·墓地存在至少1张满足检索条件的卡才能发动
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本次效果处理将把1张卡从卡组·墓地加入手卡（用于检索/回手效果的发动检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义过滤条件：自己场上表侧表示的、原本是怪兽卡且等级（原本等级）7以上的「恩底弥翁」卡
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x12a) and c:GetOriginalType()&TYPE_MONSTER>0
		and (c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
		or not c:IsType(TYPE_MONSTER) and c:GetOriginalLevel()>=7)
end
-- 效果处理：选1张满足条件的卡从卡组·墓地加入手卡并给对方确认；若自己场上有7星以上的「恩底弥翁」怪兽卡、能取除魔力指示物且对方场上有可无效的卡，则询问是否取除指示物，取除宣言数量的魔力指示物，选那个数量的对方场上表侧表示卡使其效果无效并破坏
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组·墓地选择1张满足条件且不受「王家长眠之谷」影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 若选到了卡且成功将其加入手卡，则继续后续处理
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 将加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
		-- 检查自己场上是否存在7星以上的「恩底弥翁」怪兽卡
		if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
			-- 检查自己场上是否能以效果原因取除至少1个魔力指示物
			and Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_EFFECT)
			-- 检查对方场上是否存在至少1张可以被无效的表侧表示卡
			and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否取除指示物以适用后续效果，选择「是」则继续
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否取除指示物？"
			-- 统计对方场上可以被无效的表侧表示卡的数量，作为可取除指示物数量的上限
			local ct=Duel.GetMatchingGroupCount(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
			local ctt={}
			local pc=1
			for i=1,ct do
				-- 逐个检查能否取除i个魔力指示物，把实际可宣言的数量依次存入候选表
				if Duel.IsCanRemoveCounter(tp,1,0,0x1,i,REASON_EFFECT) then ctt[i]=nil ctt[pc]=i pc=pc+1 end
			end
			ctt[pc]=nil
			-- 提示玩家选择要取除的指示物数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要取除指示物的数量"
			-- 让玩家从可宣言的数量中宣言要取除的魔力指示物数量
			local rt=Duel.AnnounceNumber(tp,table.unpack(ctt))
			-- 从自己场上取除宣言数量的魔力指示物
			Duel.RemoveCounter(tp,1,0,0x1,rt,REASON_EFFECT)
			-- 提示玩家选择要无效的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			-- 让玩家选择取除指示物数量对应的对方场上可以被无效的表侧表示卡
			local sg=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,rt,rt,nil)
			if sg:GetCount()>0 then
				-- 为选中的卡显示被选为对象的动画并记录
				Duel.HintSelection(sg)
				local ng=Group.CreateGroup()
				-- 遍历被选为无效对象的每一张卡进行处理
				for tc in aux.Next(sg) do
					if tc:IsCanBeDisabledByEffect(e,false) then
						ng:AddCard(tc)
						-- 使和该卡有关的连锁全部无效化
						Duel.NegateRelatedChain(tc,RESET_TURN_SET)
						-- 那个数量的对方场上的表侧表示卡的效果无效
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e1:SetCode(EFFECT_DISABLE)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
						-- 那个数量的对方场上的表侧表示卡的效果无效
						local e2=Effect.CreateEffect(c)
						e2:SetType(EFFECT_TYPE_SINGLE)
						e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e2:SetCode(EFFECT_DISABLE_EFFECT)
						e2:SetValue(RESET_TURN_SET)
						e2:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e2)
						if tc:IsType(TYPE_TRAPMONSTER) then
							-- 那个数量的对方场上的表侧表示卡的效果无效（若为陷阱怪兽则一并无效其陷阱怪兽状态）
							local e3=Effect.CreateEffect(c)
							e3:SetType(EFFECT_TYPE_SINGLE)
							e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
							e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
							e3:SetReset(RESET_EVENT+RESETS_STANDARD)
							tc:RegisterEffect(e3)
						end
					end
				end
				-- 立即刷新场上卡的无效状态，使无效处理生效
				Duel.AdjustInstantly()
				if ng:GetCount()>0 then
					-- 将被无效的卡全部破坏
					Duel.Destroy(ng,REASON_EFFECT)
				end
			end
		end
	end
end
