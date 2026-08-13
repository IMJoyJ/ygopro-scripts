--リブロマンサー・ライジング
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以把同名卡不在自己场上存在的1只「书灵师」怪兽从卡组加入手卡。
-- ②：自己主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「书灵师」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 创建并注册两个效果：e1为发动时的检索效果（1回合1次，自由时点发动，将符合条件的「书灵师」怪兽从卡组加入手卡）；e2为仪式召唤效果（自己主要阶段发动，将手卡·场上的怪兽解放直到等级合计达到仪式怪兽等级以上，从手卡仪式召唤「书灵师」仪式怪兽）。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以把同名卡不在自己场上存在的1只「书灵师」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- 调用辅助函数为这张卡添加仪式召唤效果：仪式怪兽过滤条件为s.ritfilter，祭品来源为手卡，无需墓地额外素材，无素材限制，且不立即注册效果（先设置属性后再注册）。
	local e2=aux.AddRitualProcGreater2(c,s.ritfilter,LOCATION_HAND,nil,nil,true)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	c:RegisterEffect(e2)
end
-- 仪式怪兽的过滤函数：判断卡片是否属于「书灵师」系列（setcard 0x17c）。
function s.ritfilter(c)
	return c:IsSetCard(0x17c)
end
-- 用于检查场上是否存在表侧表示且卡号与cd相同的卡（用来判断同名卡是否在自己场上存在）。
function s.d2hmatchfilter(c,cd)
	return c:IsFaceup() and c:IsCode(cd)
end
-- 检索卡的过滤函数：满足是怪兽、属于「书灵师」系列、可以加入手卡，并且自己场上不存在表侧表示的同名卡。
function s.d2hfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x17c) and c:IsAbleToHand()
		-- 追加条件：以当前卡的实际卡号为基准，检查自己场上不存在表侧表示的同名卡（同名卡不在自己场上存在）。
		and not Duel.IsExistingMatchingCard(s.d2hmatchfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- ①效果的发动处理：从卡组选出符合条件的「书灵师」怪兽，询问玩家是否加入手卡；若选择是，选1张加入手卡并向对方展示。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足s.d2hfilter条件的「书灵师」怪兽集合。
	local g=Duel.GetMatchingGroup(s.d2hfilter,tp,LOCATION_DECK,0,nil,tp)
	-- 若存在可选的卡且玩家确认发动检索效果，则继续处理（提示文为“是否从卡组把「书灵师」怪兽加入手卡？”）。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组把「书灵师」怪兽加入手卡？"
		-- 发送选择提示，让玩家从弹出的选卡界面中选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			-- 将选择的卡以效果原因加入其持有者的手卡（即检索加入手卡）。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡片，完成检索展示。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
